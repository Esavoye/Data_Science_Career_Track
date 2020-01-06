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
SELECT distinct facid, name, membercost FROM `Facilities` where membercost != 0

/*
facid	name	membercost	
0	Tennis Court 1	5.0
1	Tennis Court 2	5.0
4	Massage Room 1	9.9
5	Massage Room 2	9.9
6	Squash Court	3.5
*/


/* Q2: How many facilities do not charge a fee to members? */
SELECT count(name) as no_cost_count  FROM `Facilities` where membercost = 0
/*
no_cost_count
4
*/


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
 select facid, name, membercost, monthlymaintenance, membercost/monthlymaintenance*100 from Facilities where membercost != 0 having (membercost/monthlymaintenance) < 0.2


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
select * from Facilities where facid in (1, 5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
select name, monthlymaintenance, case when monthlymaintenance > 100 then 'expensive' else 'cheap' end as 'cost' from Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT firstname, surname FROM Members
WHERE joindate IN (SELECT max(joindate) FROM Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT F.name, concat(M.firstname, " ", M.surname) as member_name FROM Bookings B
left join Facilities F on B.facid = F.facid
left join Members M on B.memid = M.memid

where F.name like 'Tennis Court%'

group by F.name, concat(M.firstname, " ", M.surname)

order by concat(M.firstname, " ", M.surname), F.name

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT B.bookid, F.name, concat(M.firstname, " ", M.surname) as member_name,
	case when B.memid = 0 then B.slots * F.guestcost else B.slots * F.membercost end as Cost
FROM Bookings B
left join Facilities F on B.facid = F.facid
left join Members M on B.memid = M.memid

where B.starttime like '2012-09-14%'

having Cost > 30

order by case when B.memid = 0 then B.slots * F.guestcost else B.slots * F.membercost end desc, concat(M.firstname, " ", M.surname), F.name


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT bookid, name, member_name,
	case when B.memid = 0 then slots * guestcost else slots * membercost end as Cost

FROM (select bookid, slots, memid, facid, starttime from Bookings) B
left join (select name, facid, guestcost, membercost from Facilities) F on B.facid = F.facid
left join (select concat(firstname, " ", surname) as member_name, memid from Members) M on B.memid = M.memid

where B.starttime like '2012-09-14%'

having Cost > 30


order by case when B.memid = 0 then slots * guestcost else slots * membercost end desc, member_name, name


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

select CT.name, sum(CT.Revenue) as Total_Revenue
from 

(
SELECT F.name, B.bookid, B.memid, B.slots, F.guestcost, F.membercost,
case when B.memid = 0 then B.slots * F.guestcost else B.slots * F.membercost end as Revenue

FROM Bookings B
left join Facilities F on B.facid = F.facid
left join Members M on B.memid = M.memid

) CT

group by CT.name

having Total_Revenue < 1000

order by CT.name




