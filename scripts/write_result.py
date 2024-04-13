import os
import sys
import csv
import gspread
from oauth2client.service_account import ServiceAccountCredentials

def main():

    if len(sys.argv) < 5:
        print("Usage: write_result.py <sheet name> <matchnum> <host> <result.csv>")
        return

    sheet_name=sys.argv[1]
    match_num=sys.argv[2]
    host=sys.argv[3]
    resultfile=sys.argv[4]

    try:
        f = open(resultfile, 'r')
    except FileNotFoundError:
        print("File not found")
        return

    scope = ['https://spreadsheets.google.com/feeds']
    doc_id = 'Your doc id'
    path = os.path.expanduser("Path of json file")

    credentials = ServiceAccountCredentials.from_json_keyfile_name(path, scope)
    client = gspread.authorize(credentials)
    spreadsheet= client.open_by_key(doc_id)
    try:
        worksheet = spreadsheet.worksheet(sheet_name)
    except gspread.exceptions.WorksheetNotFound:
        worksheet = spreadsheet.add_worksheet(sheet_name,100,8)

    reader = csv.reader(f)
    header = next(reader)
    #print(header)
    for row in reader:
        game_time=row[0]
        left_name=row[1].replace('"', '').replace(' ', '')
        right_name=row[2].replace('"', '').replace(' ', '')
        left_score=int(row[5])
        right_score=int(row[6])
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
        worksheet.append_row(data)
    f.close()

if __name__ == '__main__':
    main()
