#!/usr/bin/env python3
import os
import sys
import csv
import io
from datetime import datetime, timedelta

from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseUpload
import google.auth
import requests


DATA_PATH = os.path.join(os.path.dirname(__file__), "..", ".data", "kamatera_usage")
KEEP_PREFIXES = ("hasadna-", "k972il-")
KEEP_COLUMNS = [
    "User ID",
    "Customer ID",
    "Datacenter",
    "Service Type",
    "Service Name",
    "Unit Size",
    "Billing Cycle",
    "Cost per Cycle",
    "Start",
    "End",
    "Units Count",
    "Due Date",
    "Total Cost",
    "IP",
]


def parse_float(val):
    try:
        return float(val)
    except (TypeError, ValueError):
        return 0.0


def download_data(year, month):
    filename = os.path.join(DATA_PATH, f"{year}-{month}__{datetime.now().strftime('%Y%m%d')}.csv")
    if os.path.exists(filename):
        print(f'Loading Kamatera usage from cache: {filename}...', file=sys.stderr)
        with open(filename, "r") as f:
            return f.read()
    else:
        print(f'Fetching Kamatera usage for {year}-{month}...', file=sys.stderr)
        response = requests.get(
            f"https://console.kamatera.com/service/billing/{year}/{month}/self",
            headers={
                "Content-Type": "application/json",
                "AuthClientId": os.environ["KAMATERA_API_CLIENT_ID"],
                "AuthSecret": os.environ["KAMATERA_API_SECRET"],
            },
        )
        response.raise_for_status()
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        with open(filename, "w") as f:
            f.write(response.text)
        return response.text


def get_drive_services():
    scopes = [
        "https://www.googleapis.com/auth/drive",
        "https://www.googleapis.com/auth/spreadsheets",
    ]
    creds, _ = google.auth.default(scopes=scopes)
    drive = build("drive", "v3", credentials=creds, cache_discovery=False)
    sheets = build("sheets", "v4", credentials=creds, cache_discovery=False)
    return drive, sheets


def get_or_create_subfolder(drive, parent_id: str, name: str) -> str:
    q = (
        "mimeType='application/vnd.google-apps.folder' "
        f"and name='{name.replace('\'', '\\\'')}' "
        f"and '{parent_id}' in parents and trashed=false"
    )
    res = drive.files().list(
        q=q,
        spaces="drive",
        fields="files(id,name)",
        supportsAllDrives=True,
        includeItemsFromAllDrives=True,
        pageSize=10,
    ).execute()
    files = res.get("files", [])
    if files:
        return files[0]["id"]
    folder = drive.files().create(
        body={
            "name": name,
            "mimeType": "application/vnd.google-apps.folder",
            "parents": [parent_id],
        },
        fields="id",
        supportsAllDrives=True,
    ).execute()
    return folder["id"]


def upload_csv_as_google_sheet(
    drive,
    sheets,
    parent_folder_id: str,
    sheet_name: str,
    csv_text: str,
):
    existing_id = find_sheet_in_folder(drive, parent_folder_id, sheet_name)
    if existing_id:
        overwrite_google_sheet_from_csv(sheets, existing_id, csv_text)
        return existing_id, "overwritten"
    media = MediaIoBaseUpload(
        io.BytesIO(csv_text.encode("utf-8")),
        mimetype="text/csv",
        resumable=False,
    )
    created = drive.files().create(
        body={
            "name": sheet_name,
            "mimeType": "application/vnd.google-apps.spreadsheet",
            "parents": [parent_folder_id],
        },
        media_body=media,
        fields="id",
        supportsAllDrives=True,
    ).execute()
    return created["id"], "created"


def find_sheet_in_folder(drive, parent_folder_id: str, name: str):
    q = (
        "mimeType='application/vnd.google-apps.spreadsheet' "
        f"and name='{name.replace('\'', '\\\'')}' "
        f"and '{parent_folder_id}' in parents "
        "and trashed=false"
    )
    res = drive.files().list(
        q=q,
        spaces="drive",
        fields="files(id,name)",
        supportsAllDrives=True,
        includeItemsFromAllDrives=True,
        pageSize=2,
    ).execute()
    files = res.get("files", [])
    if not files:
        return None
    if len(files) > 1:
        raise RuntimeError(f"Multiple sheets named '{name}' found in folder")
    return files[0]["id"]


def overwrite_google_sheet_from_csv(sheets, spreadsheet_id: str, csv_text: str):
    rows = list(csv.reader(io.StringIO(csv_text)))
    title = get_first_sheet_title(sheets, spreadsheet_id)
    sheets.spreadsheets().values().clear(
        spreadsheetId=spreadsheet_id,
        range=f"{title}!A:ZZZ",
    ).execute()
    sheets.spreadsheets().values().update(
        spreadsheetId=spreadsheet_id,
        range=f"{title}!A1",
        valueInputOption="RAW",
        body={"values": rows},
    ).execute()


def upload_to_gdrive(output, year, month, output_file):
    print('Uploading to Google Drive...', file=sys.stderr)
    root_folder_id = output.split("://", 1)[1]
    drive, sheets = get_drive_services()
    debug_folder_location(drive, root_folder_id)
    year_folder_id = get_or_create_subfolder(drive, root_folder_id, str(year))
    sheet_title = f"kamatera usage {month}.{year}"
    sheet_id, action = upload_csv_as_google_sheet(
        drive=drive,
        sheets=sheets,
        parent_folder_id=year_folder_id,
        sheet_name=sheet_title,
        csv_text=output_file.getvalue(),
    )
    print(f"Google Sheet {action}: {sheet_title}", file=sys.stderr)


def get_first_sheet_title(sheets, spreadsheet_id: str) -> str:
    meta = sheets.spreadsheets().get(
        spreadsheetId=spreadsheet_id,
        fields="sheets(properties(title))",
    ).execute()
    sheet_list = meta.get("sheets", [])
    if not sheet_list:
        raise RuntimeError("Spreadsheet has no sheets/tabs")
    return sheet_list[0]["properties"]["title"]


def debug_folder_location(drive, folder_id: str):
    meta = drive.files().get(
        fileId=folder_id,
        fields="id,name,driveId,parents,owners(emailAddress),capabilities",
        supportsAllDrives=True,
    ).execute()
    print(meta, file=sys.stderr)


def main(year=None, month=None, output=None):
    if output is None:
        output = f'gdrive://{os.environ["GOOGLE_DRIVE_FOLDER_ID"]}'
    if year is None and month is None:
        now = datetime.now()
        if now.day <= 3:
            print('within first 3 days of month, not updating', file=sys.stderr)
            return
        if now.day >= 10:
            print('after 10th of month, not updating', file=sys.stderr)
            return
        last_month = now.replace(day=1) - timedelta(days=1)
        year = last_month.year
        month = last_month.month
        print(f'No year/month specified, using last month: {year}-{month:02d}', file=sys.stderr)
    assert year and month and output
    csv_data = download_data(year, month)
    print('Processing CSV data...', file=sys.stderr)
    reader = csv.DictReader(io.StringIO(csv_data))
    header_map = {h.lower(): h for h in reader.fieldnames or []}
    resolved_columns = []
    for col in KEEP_COLUMNS:
        key = col.lower()
        if key not in header_map:
            raise ValueError(f"Required column not found in CSV: {col}")
        resolved_columns.append(header_map[key])
    is_gdrive = output.startswith("gdrive://")
    if output == '-':
        output_file = sys.stdout
    elif is_gdrive:
        output_file = io.StringIO()
    else:
        output_file = open(output, "w", newline="")
    try:
        writer = csv.DictWriter(
            output_file,
            fieldnames=KEEP_COLUMNS,
            lineterminator="\n",
        )
        writer.writeheader()
        timestamp = datetime.now().isoformat(sep=" ", timespec="seconds")
        writer.writerow({KEEP_COLUMNS[0]: f"Generated at: {timestamp}"})
        for row in reader:
            service_name = row.get(header_map["service name"], "")
            if not service_name.lower().startswith(KEEP_PREFIXES):
                continue
            total_cost = parse_float(row.get(header_map["total cost"]))
            if total_cost <= 1:
                continue
            out_row = {}
            for original_col, output_col in zip(resolved_columns, KEEP_COLUMNS):
                out_row[output_col] = row.get(original_col, "")
            writer.writerow(out_row)
    finally:
        if output != '-' and not is_gdrive:
            output_file.close()
    if is_gdrive:
        upload_to_gdrive(output, year, month, output_file)
    print('Done.', file=sys.stderr)


if __name__ == "__main__":
    if len(sys.argv) != 4 and len(sys.argv) != 1:
        print("Usage: script.py [<year> <month> <output>]", file=sys.stderr)
        print("""
To test gdrive upload:

with local user:
gcloud auth application-default login \
  --scopes="https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/drive,https://www.googleapis.com/auth/spreadsheets,openid,email"
gcloud auth application-default set-quota-project hasadna-general

with service account:
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your-service-account-key.json"
""")
        sys.exit(1)

    main(*sys.argv[1:])
