

import cgi
import json
import mysql.connector

print("Content-Type: application/json")
print()

# Retrieve the parameters
form = cgi.FieldStorage()
campus = form.getvalue('campus', 'UHWO')
cuisine = form.getvalue('cuisine', '')
place = form.getvalue('place', '')

# Check required parameters are present
if not campus or not place:
    print(json.dumps({
        'msg': 'campus or place not specified',
        'error': '1',
        'campus': campus,
        'cuisine': cuisine,
        'place': place
    }))
    exit()

# Connect to the database and call the ADD_PLACE
try:
    conn = mysql.connector.connect(
        user='coryl321',
        password='uxTzQ@TMQt^Vjx@zD%cmrchS47RP*F$PFNvVeY3o',
        host='localhost',
        database='{}_CAMPUS'.format('coryl321')
    )
    cursor = conn.cursor()
    result_args = cursor.callproc('ADD_PLACE', [campus, cuisine, place, '', ''])
    err = result_args[-2]
    msg = result_args[-1]
    cursor.close()
    conn.commit()
    conn.close()
except mysql.connector.Error as err:
    print(json.dumps({
        'msg': str(err),
        'error': '1',
        'campus': campus,
        'cuisine': cuisine,
        'place': place
    }))
    exit()

# Return as JSON
print(json.dumps({
    'msg': msg,
    'error': err,
    'campus': campus,
    'cuisine': cuisine,
    'place': place
}))
