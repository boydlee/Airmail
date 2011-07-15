
import sqlite3


#connect to sqlite databse
conn = sqlite3.connect('data.db')
c = conn.cursor()

# drop existed table
c.execute('''drop table if exists feeds''')
# Create table
c.execute('''create table feeds 
	(id integer primary key, url varchar(500) not null, xml text)  ''')	

	
# Save (commit) the changes
conn.commit()

# We can also close the cursor if we are done with it
c.close()