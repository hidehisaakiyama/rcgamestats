import os
import sys
import gspread
from oauth2client.service_account import ServiceAccountCredentials

def main():

    if len(sys.argv) < 4:
        print("Usage: create-sheet.py <sheet_name> <datetime> <opponent_name> [group_tag]")
        return

    sheet_name=sys.argv[1]
    datetime=sys.argv[2]
    opponent_name=sys.argv[3]
    if len(sys.argv) == 5:
        group_tag=sys.argv[4]
    else:
        group_tag=""

    scope = ['https://spreadsheets.google.com/feeds']
    doc_id = 'Your doc id'
    path = os.path.expanduser("Path of json file")

    credentials = ServiceAccountCredentials.from_json_keyfile_name(path, scope)
    client = gspread.authorize(credentials)
    spreadsheet= client.open_by_key(doc_id)
    try:
        group_sheet = spreadsheet.worksheet(sheet_name)
        print("group sheet already exists.")
#        return
    except gspread.exceptions.WorksheetNotFound:
        print("create new group sheet " + sheet_name)
        group_sheet = spreadsheet.add_worksheet(sheet_name,100,8)


    try:
        summary_sheet = spreadsheet.worksheet('summary')
    except gspread.exceptions.WorksheetNotFound:
        print("create summary sheet")
        summary_sheet = spreadsheet.add_worksheet('summary',100,12)
#        header = [ '', '# of match', 'win', 'draw', 'lose', 'goal scored', 'goal conceded', 'win rate', 'lose rate']
        header = [ 'group_name', 'datetime', 'opponent', 'tag', '# of game', 'win', 'draw', 'lose', 'goal', 'conceded', 'win rate', 'draw rate', 'lose rate', 'ave goal', 'ave conceded', 'max goal', 'max conceded', '# of scored', "# of conceded", 'scored rate', 'conceded rate' ]
        summary_sheet.append_row(header)


    #
    # insert a summary row for the new sheet

#    num_match = '=C2+D2+E2'
    num_match = '=F2+G2+H2'
    win = '=COUNTIF(\''+ sheet_name + '\'!$H$1:$H$1000,1)'
    draw = '=COUNTIF(\''+ sheet_name + '\'!$H$1:$H$1000,0)'
    lose = '=COUNTIF(\''+ sheet_name + '\'!$H$1:$H$1000,-1)'
    goal_scored = '=SUM(\'' + sheet_name + '\'!$F$1:$F$1000)'
    goal_conceded = '=SUM(\'' + sheet_name + '\'!$G$1:$G$1000)'
#    win_rate = '=C2/B2'
#    lose_rate = '=E2/B2'
    win_rate = '=F2/E2'
    draw_rate = '=G2/E2'
    lose_rate = '=H2/E2'
    ave_goal = '=I2/E2' # N2
    ave_conceded = '=J2/E2' # Q2
    max_goal = '=MAX(\'' + sheet_name + '\'!$F$1:$F$1000)'
    max_conceded = '=MAX(\'' + sheet_name + '\'!$G$1:$G$1000)'
    n_scored = '=COUNTIF(\''+ sheet_name + '\'!$F$1:$F$1000,">0")'
    n_conceded = '=COUNTIF(\''+ sheet_name + '\'!$G$1:$G$1000,">0")'
    scored_rate = '=R2/E2'
    conceded_rate = '=S2/E2'
#    stddeva_goal = '=STDEVA(\''+ sheet_name + '\'!$F$1:$F$1000)' # T2
#    ave_goal_conf95 = '=CONFIDENCE.T(0.05,T2,E2)' # U2
#    ave_goal_interval1 = '=N2-U2'
#    ave_goal_interval2 = '=N2+U2'

#    stddeva_conceded = '=STDEVA(\''+ sheet_name + '\'!$G$1:$G$1000)' # V2
#    ave_conceded_conf95 = '=CONFIDENCE.T(0.05,V2,E2)' # W2
#    ave_conceded_interval1 = '=Q2-W2'
#    ave_conceded_interval2 = '=Q2+W2'


#    data = [sheet_name, num_match, win, draw, lose, '', goal_scored, goal_conceded, '', win_rate, lose_rate]
    #data = [sheet_name, datetime, opponent_name, group_tag, num_match, win, draw, lose, goal_scored, goal_conceded, win_rate, lose_rate, ave_goal, ave_conceded]
    data = [sheet_name, datetime, opponent_name, group_tag, num_match, win, draw, lose, goal_scored, goal_conceded, win_rate, draw_rate, lose_rate, ave_goal, ave_conceded, max_goal, max_conceded, n_scored, n_conceded, scored_rate, conceded_rate]
#    data = [sheet_name, datetime, opponent_name, group_tag, num_match, win, draw, lose, goal_scored, goal_conceded, win_rate, draw_rate, lose_rate, ave_goal, ave_goal_interval1, ave_goal_interval2, ave_conceded, ave_conceded_interval1, ave_conceded_interval2, stddeva_goal, ave_goal_conf95, stddeva_conceded, ave_conceded_conf95]
#    print(data)
    summary_sheet.insert_row(values=data,index=2,value_input_option='USER_ENTERED')

if __name__ == '__main__':
    main()
