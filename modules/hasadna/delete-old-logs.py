import os
import sys
from datetime import datetime
import shutil


def delete_old_files(root_path, cutoff_date):
    for root, dirs, files in os.walk(root_path, topdown=False):
        for name in files:
            file_path = os.path.join(root, name)
            try:
                mod_date = datetime.fromtimestamp(os.path.getmtime(file_path))
            except FileNotFoundError:
                mod_date = None
            if mod_date is not None and mod_date < cutoff_date:
                # print(f'remove: {file_path}')
                os.remove(file_path)

        # Check if the directory is empty after file deletion
        if not os.listdir(root):
            # print(f'rmtree: {root}')
            shutil.rmtree(root)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py [path] [date in YYYY-MM-DD format]")
        sys.exit(1)

    path = sys.argv[1]
    date_str = sys.argv[2]

    try:
        cutoff_date = datetime.strptime(date_str, "%Y-%m-%d")
    except ValueError:
        print("Invalid date format. Please use YYYY-MM-DD.")
        sys.exit(1)

    delete_old_files(path, cutoff_date)
