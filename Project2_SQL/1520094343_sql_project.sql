/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name FROM `Facilities` 
WHERE membercost = 0;

/* Q2: How many facilities do not charge a fee to members? */

SELECT count(name) FROM `Facilities` 
WHERE membercost = 0;

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the  offacid, facility name, member cost, and monthly maintenance the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance FROM `Facilities` 
WHERE membercost < 0.2*monthlymaintenance AND membercost > 0;


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT * FROM `Facilities` 
WHERE facid IN (1,5);

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

/*USING SQL's if-then  methods, label the monthlypaintenance as "expensive" when
it's above 100*/
SELECT name,
CASE WHEN (monthlymaintenance > 100) THEN "expensive"
	ELSE "cheap"
END AS monthlymaintenance
FROM `Facilities`;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

/*The MAX function allows to select the newest date when used on a date
column*/
SELECT firstname, surname, MAX(starttime) FROM Members
JOIN Bookings
ON Members.memid = Bookings.memid

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT CONCAT(firstname,' ', surname) AS member_name, Facilities.name 
FROM Members
/*Need to join all three tables in order to get access to member names
and facility names*/
JOIN Bookings
ON Members.memid = Bookings.memid
JOIN Facilities
ON Bookings.facid = Facilities.facid
WHERE Facilities.name LIKE "Tennis%"
ORDER BY member_name

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */


SELECT CONCAT(firstname,' ', surname) AS Member, Facilities.name as Facility,
/*SELECT ANOTHER COLUMN 'COST' BASED ON:
if the memid is 0 then select the guest cost else select member cost 
from the facilities table*/
CASE WHEN Bookings.memid = 0 
	THEN Bookings.slots * Facilities.guestcost
	ELSE Bookings.slots * Facilities.membercost
END AS Cost

/*joining all three tables using inner join*/
FROM Members
INNER JOIN Bookings
ON Members.memid = Bookings.memid
INNER JOIN Facilities
ON Bookings.facid = Facilities.facid

WHERE Bookings.starttime >= '2012-09-14' AND
	  Bookings.starttime <  '2012-09-15' AND
	  (
	  	(Members.memid = 0 AND Bookings.slots * Facilities.guestcost > 30) OR
	  	(Members.memid !=0 AND Bookings.slots * Facilities.membercost > 30)
	  ) 
ORDER BY Cost DESC;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT Member, Facility, Cost FROM(
    
	SELECT concat(firstname, ' ', surname) AS Member, Facilities.name as Facility,

	CASE WHEN Bookings.memid = 0 
		THEN Bookings.slots * Facilities.guestcost
		ELSE Bookings.slots * Facilities.membercost
	END AS Cost

	FROM Members
	INNER JOIN Bookings
	ON Members.memid = Bookings.memid
	INNER JOIN Facilities
	ON Bookings.facid = Facilities.facid

	WHERE Bookings.starttime >= '2012-09-14' AND
		  Bookings.starttime <  '2012-09-15'
	) as bookings

WHERE Cost > 30
ORDER BY cost DESC;


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT Facilities.name as name, 
/*Define the second colum, "Revenue" using the SUM method on the total
revenue. Revenue calculated based on member cost * number of slots and
guest cost * number of slots. Then the cost per slot is summed up as 
revenue*/
SUM(CASE WHEN Bookings.memid = 0 
		THEN Bookings.slots * Facilities.guestcost
		ELSE Bookings.slots * Facilities.membercost
	END) AS Revenue
FROM Facilities
/*Need to join facilities to bookings in order to get access to the 
facility name and booking ammounts.*/
INNER JOIN Bookings
ON Bookings.facid = Facilities.facid
GROUP BY name
HAVING Revenue < 1000








