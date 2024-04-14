import os
import sys
import csv
import gspread
from oauth2client.service_account import ServiceAccountCredentials

def main():

    if len(sys.argv) < 4:
        print("Usage: write_result.py <doc_id> <key_file> <queued_results.csv>")
        return

    doc_id = sys.argv[1]
    key_file = os.path.expanduser(sys.argv[2])
    resultfile=sys.argv[3]

    try:
        f = open(resultfile, 'r')
    except FileNotFoundError:
        print("File not found")
        return

    scope = ['https://spreadsheets.google.com/feeds']
    #doc_id = 'Your doc id'
    #key_file = os.path.expanduser("Path of json file")

    credentials = ServiceAccountCredentials.from_json_keyfile_name(key_file, scope)
    client = gspread.authorize(credentials)
    spreadsheet = client.open_by_key(doc_id)

    sheet_name = os.path.splitext( os.path.basename( resultfile ) )[0]
    try:
        worksheet = spreadsheet.worksheet(sheet_name)
    except gspread.exceptions.WorksheetNotFound:
        worksheet = spreadsheet.add_worksheet(sheet_name,100,8)

    reader = csv.reader(f)
    header = next(reader)
    #print(header)

    all_rows = []
    for row in reader:
        match_num = int(row[0].strip())
        host = row[1].strip()
        game_time = row[2]
        left_name = row[3].replace('"', '').replace(' ', '')
        right_name = row[4].replace('"', '').replace(' ', '')
        left_score = int(row[7])
        right_score = int(row[8])
        point=0
        if left_score > right_score:
            #print("win")
            point=1
        elif left_score < right_score:
            #print("lose")
            point=-1
        else:
            #print("draw")
            point=0

        if left_name == 'NULL' or right_name == 'NULL':
            print("write_result.py: No team")
            continue

        data = [str(match_num).zfill(3), host, game_time, left_name, right_name, left_score, right_score, point]

        print(data)
        all_rows.append(data)

    worksheet.append_rows(all_rows)
    f.close()

if __name__ == '__main__':
    main()
