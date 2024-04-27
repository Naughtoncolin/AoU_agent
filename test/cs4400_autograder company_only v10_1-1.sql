-- CS4400: Introduction to Database Systems: Wednesday, September 7, 2022
-- SQL Autograding Environment (v10.3): Company Database (PRACTICE ONLY)
-- Version 10.3: Reset database state after testing w/magic44_set_database_state()

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;
set @thisDatabase = 'company';

-- -------------------------------------------------
-- ENTER YOUR QUERY SOLUTIONS STARTING AT LINE 90
-- -------------------------------------------------

drop database if exists company;
create database if not exists company;
use company;

-- -----------------------------------------------
-- table structures
-- -----------------------------------------------

create table employee (
  fname char(10) not null,
  lname char(20) not null,
  ssn decimal(9, 0) not null,
  bdate date not null,
  address char(30) not null,
  sex char(1) not null,
  salary decimal(5, 0) not null,
  superssn decimal(9, 0) default null,
  dno decimal(1, 0) not null,
  primary key (ssn)
) engine = innodb;

create table dependent (
  essn decimal(9, 0) not null,
  dependent_name char(10) not null,
  sex char(1) not null,
  bdate date not null,
  relationship char(30) not null,
  primary key (essn, dependent_name)
) engine = innodb;

create table department (
  dname char(20) not null,
  dnumber decimal(1, 0) not null,
  mgrssn decimal(9, 0) not null,
  mgrstartdate date not null,
  primary key (dnumber),
  unique key (dname)
) engine = innodb;

create table dept_locations (
  dnumber decimal(1, 0) not null,
  dlocation char(15) not null,
  primary key (dnumber, dlocation)
) engine = innodb;

create table project (
  pname char(20) not null,
  pnumber decimal(2, 0) not null,
  plocation char(20) not null,
  dnum decimal(1, 0) not null,
  primary key (pnumber),
  unique key (pname)
) engine = innodb;

create table works_on (
  essn decimal(9, 0) not null,
  pno decimal(2, 0) not null,
  hours decimal(5, 1) default null,
  primary key (essn, pno)
) engine = innodb;

-- Enter your queries in the area below using this format:
-- create or replace view practiceQuery<#> as
-- <your proposed query solution>;

-- Be sure to end all queries with a semi-colon (';') and make sure that
-- the <#> value matches the query value from the practice sheet

-- -------------------------------------------------
-- view structures (student created solutions)
-- PUT ALL PROPOSED QUERY SOLUTIONS BELOW THIS LINE
-- -------------------------------------------------
-- CS4400: Introduction to Database Systems
-- Company ANSWER KEY (v5 - Actual Queries for Book and Other Practice Problems)
-- Friday, July 14, 2023

-- [Tue, 19 May 2020: Fixed practice query 51 / Reversed the order of the first and last names]
-- [Sat, 23 May 2020: Fixed practice queries 25-27 / Switched project number & name columns]
-- [Sun, 28 Nov 2021: Fixed practice query 15 / Corrected project assignments to emps not depts]
-- [Fri, 14 Jul 2023: "Re"-updated queries 3, 15 and 25-27 / As shown above]

-- practiceQuery0: Retrieve birthdate and address for 'John Smith'.
drop view if exists practiceQuery0;
create view practiceQuery0 as 
select bdate, address from employee where fname = 'John' and lname = 'Smith';

-- practiceQuery1: Retrieve the first name, last name and address of all employees who work for the 'Research' department.
drop view if exists practiceQuery1;
create view practiceQuery1 as 
select fname, lname, address from employee where dno in (select dnumber from department where dname = 'Research');

-- practiceQuery2: For every project located in 'Stafford', list the project number, the controlling department number, and the department manager's last name, address, and birth date.
drop view if exists practiceQuery2;
create view practiceQuery2 as 
select pnumber, dnum, lname, address, bdate from project, department, employee where dnum = dnumber and mgrssn = ssn and plocation = 'Stafford';

-- practiceQuery3: Find the names of employees who work on all the projects controlled by department number 5.
drop view if exists practiceQuery3;
create view practiceQuery3 as
select fname, lname from employee
where not exists (select pnumber from project where dnum = 5
and pnumber not in (select pno from works_on where ssn = essn));

-- practiceQuery4: Make a list of project numbers for projects that involve an employee whose last name is 'Smith', either as a worker or as a manager of the department that controls the project.
drop view if exists practiceQuery4;
create view practiceQuery4 as 
(select pno from works_on, employee where essn = ssn and lname = 'Smith') union
(select pnumber from project, department, employee where dnum = dnumber and mgrssn = ssn and lname = 'Smith');

-- practiceQuery5: List the names of all employees with two or more dependents.
drop view if exists practiceQuery5;
create view practiceQuery5 as 
select fname, lname from employee where ssn in
(select essn from dependent group by essn having count(*) >= 2);

-- practiceQuery6: Retrieve the names of employees who have no dependents.
drop view if exists practiceQuery6;
create view practiceQuery6 as 
select fname, lname from employee where ssn not in
(select essn from dependent);

-- practiceQuery7: List the names of managers who have at least one dependent.
drop view if exists practiceQuery7;
create view practiceQuery7 as 
select fname, lname from employee where ssn in (select essn from dependent)
and ssn in (select mgrssn from department);

-- practiceQuery8: For each employee, retrieve the employee's first and last name and the first and last name of his or her immediate supervisor.
drop view if exists practiceQuery8;
create view practiceQuery8 as 
select tableA.fname as A_fname, tableA.lname as A_lname, tableB.fname as B_fname, tableB.lname as B_lname
from employee as tableA left outer join employee as tableB on tableA.superssn = tableB.ssn;

-- practiceQuery9: Select all of the employee's Social Security Numbers.
drop view if exists practiceQuery9;
create view practiceQuery9 as 
select ssn from employee;

-- practiceQuery10: Select all possible combinations of the employee's Social Security Numbers and department names.
drop view if exists practiceQuery10;
create view practiceQuery10 as 
select ssn, dname from employee, department;

-- practiceQuery11: Retrieve the distinct salaries of all of the employees.
drop view if exists practiceQuery11;
create view practiceQuery11 as 
select distinct salary from employee;

-- practiceQuery12: Retrieve the first and last names of all employees whose address is in Houston, Texas.
drop view if exists practiceQuery12;
create view practiceQuery12 as 
select fname, lname from employee where address like '%Houston TX%';

-- practiceQuery13: Show the first and last names and resulting salaries if every employee working on the 'ProductX' project is given a 10% raise.
drop view if exists practiceQuery13;
create view practiceQuery13 as 
select fname, lname, salary from employee where ssn not in
(select essn from works_on, project where pno = pnumber and pname = 'ProductX')
union
select fname, lname, salary * 1.10 from employee where ssn in
(select essn from works_on, project where pno = pnumber and pname = 'ProductX');

-- practiceQuery14: Retrieve all information for employees in department 5 whose salary is between $30,000 and $40,000.
drop view if exists practiceQuery14;
create view practiceQuery14 as 
select * from employee where dno = 5 and salary between 30000 and 40000;

-- practiceQuery15: Retrieve a list of department names, employee first and last names, and the project names they are working on, ordered by department and, within each department, alphabetically by last name, then first name.
drop view if exists practiceQuery15;
create view practiceQuery15 as 
select dname, lname, fname, pname from department, employee, works_on, project
where dnumber = dno and ssn = essn and pno = pnumber
order by dname, lname, fname;

-- practiceQuery16: Retrieve the name of each employee who has a dependent with the same first name and is the same sex as the employee.
drop view if exists practiceQuery16;
create view practiceQuery16 as 
select distinct fname, lname from employee, dependent
where ssn = essn and fname = dependent_name and employee.sex = dependent.sex;

-- practiceQuery17: Retrieve the SSNs of employees who work on projects with numbers 1, 2, or 3.
drop view if exists practiceQuery17;
create view practiceQuery17 as 
select ssn from employee where ssn in (select essn from works_on where pno in (1, 2, 3));

-- practiceQuery18: Retrieve the names of all employees who do not have supervisors.
drop view if exists practiceQuery18;
create view practiceQuery18 as 
select fname, lname from employee where superssn is null;

-- practiceQuery19: Find the sum of the salaries of all employees, the maximum salary, the minimum salary, and the average salary.
drop view if exists practiceQuery19;
create view practiceQuery19 as 
select sum(salary), max(salary), min(salary), avg(salary) from employee;

-- practiceQuery20: Find the sum of the salaries of all employees of the 'Research' department, as well as the maximum salary, the minimum salary, and the average salary in this department.
drop view if exists practiceQuery20;
create view practiceQuery20 as 
select sum(salary), max(salary), min(salary), avg(salary) from employee where dno in
(select dnumber from department where dname = 'Research');

-- practiceQuery21: Retrieve the total number of employees in the company.
drop view if exists practiceQuery21;
create view practiceQuery21 as 
select count(*) from employee;

-- practiceQuery22: Retrieve the total number of employees in the 'Research' department.
drop view if exists practiceQuery22;
create view practiceQuery22 as 
select count(*) from employee where dno in
(select dnumber from department where dname = 'Research');

-- practiceQuery23: Count the number of distinct salary values in the database.
drop view if exists practiceQuery23;
create view practiceQuery23 as 
select count(distinct salary) from employee;

-- practiceQuery24: For each department, retrieve the department number, the number of employees in the department, and their average salary.
drop view if exists practiceQuery24;
create view practiceQuery24 as 
select dnumber, count(ssn), avg(salary) from department, employee where dnumber = dno group by dnumber
union (select dnumber, 0, 0 from department where dnumber not in (select dno from employee));

-- practiceQuery25: For each project, retrieve the project number, the project name, and the number of employees who work on that project. (Null employees will be interpreted as zero employees).
drop view if exists practiceQuery25;
create view practiceQuery25 as 
select pnumber, pname, count(distinct essn) from project left outer join works_on
on pnumber = pno group by pname, pnumber;

-- practiceQuery26: For each project on which more than two employees work, retrieve the project number, the project name, and the number of employees who work on the project.
drop view if exists practiceQuery26;
create view practiceQuery26 as 
select pnumber, pname, count(distinct essn) from project left outer join works_on
on pnumber = pno group by pname, pnumber having count(distinct essn) > 2;

-- practiceQuery27: For each project, retrieve the project number, the project name, and the number of employees from department 5 who work on the project.
drop view if exists practiceQuery27;
create view practiceQuery27 as 
select pnumber, pname, count(distinct essn) from project left outer join
(select essn , pno from works_on where essn in (select ssn from employee where dno = 5)) as temp
on pnumber = pno group by pname, pnumber;

-- practiceQuery28: For each department that has less than four* employees, retrieve the department number and the number of its employees who are making more than $25,000*. (Less than four employees instead of more than five, and $25,000 instead of $40,000 to make the results more fruitful.)
drop view if exists practiceQuery28;
create view practiceQuery28 as 
select dno, count(ssn) from employee where salary > 25000 and dno in
(select dno from employee group by dno having count(ssn) < 4) group by dno;

-- practiceQuery29: Retrieve all of the attribute values for any employee who works in department 5.
drop view if exists practiceQuery29;
create view practiceQuery29 as 
select * from employee where dno = 5;

-- practiceQuery30: Retrieve all of the attributes for each employee and the department for which he or she works.
drop view if exists practiceQuery30;
create view practiceQuery30 as 
select * from employee, department where dno = dnumber;

-- practiceQuery31: Find the first name, last name and birthdate of the employees who were born during the 1950s.
drop view if exists practiceQuery31;
create view practiceQuery31 as 
select fname, lname, bdate from employee where bdate between '1950-01-01' and '1959-12-31';

-- practiceQuery32: Retrieve the first and last names of all employees in department 5 who work more than 10 hours per week on the ProductX project.
drop view if exists practiceQuery32;
create view practiceQuery32 as 
select fname, lname from employee where dno = 5 and ssn in (select essn from works_on where pno in
(select pnumber from project where pname = 'ProductX') group by essn having sum(hours) > 10);

-- practiceQuery33: List the first and last names of all employees who have a dependent with the same first name as themselves.
drop view if exists practiceQuery33;
create view practiceQuery33 as 
select fname, lname from employee, dependent where ssn = essn and fname = dependent_name;

-- practiceQuery34: Find the first and last names of all employees who are directly supervised by 'Franklin Wong'.
drop view if exists practiceQuery34;
create view practiceQuery34 as 
select fname, lname from employee
where superssn = (select ssn from employee where fname = 'Franklin' and lname = 'Wong');

-- practiceQuery35: Retrieve the first and last names of all employees who work in the department that has the employee with the highest salary among all employees.
drop view if exists practiceQuery35;
create view practiceQuery35 as 
select fname, lname from employee where dno in
(select dno from employee group by dno having max(salary) >= (select max(salary) from employee));

-- practiceQuery36: Retrieve the first and last names of all employees whose supervisor's supervisor has '888665555' for their SSN.
drop view if exists practiceQuery36;
create view practiceQuery36 as 
select fname, lname from employee where superssn in
(select ssn from employee where superssn = '888665555');

-- practiceQuery37: Retrieve the first and last names of employees who make at least $10,000 more than the employee who is paid the least in the company.
drop view if exists practiceQuery37;
create view practiceQuery37 as 
select fname, lname from employee where salary >= (select min(salary) from employee) + 10000;

-- practiceQuery40: Return a static string 'Hello World!'.
drop view if exists practiceQuery40;
create view practiceQuery40 as 
select 'Hello World!';

-- practiceQuery41: Return a static string 'Hello World!' with column alias 'greeting'.
drop view if exists practiceQuery41;
create view practiceQuery41 as 
select 'Hello World!' as 'greeting';

-- practiceQuery42: Compute the sum of 4 and 6.
drop view if exists practiceQuery42;
create view practiceQuery42 as 
select 4 + 6;

-- practiceQuery43: Compute several arithmetic operations and return their results with column aliases.
drop view if exists practiceQuery43;
create view practiceQuery43 as 
select 4 + 6 as 'my_sum', 3 * 7 as 'my_product', 9 - 5 as 'my_difference';

-- practiceQuery44: Retrieve all columns for all employees.
drop view if exists practiceQuery44;
create view practiceQuery44 as 
select * from employee;

-- practiceQuery50: Retrieve first name, last name, and address of all employees.
drop view if exists practiceQuery50;
create view practiceQuery50 as 
select fname, lname, address from employee;

-- practiceQuery51: Display the last name in a column titled 'Last Name', first name in a column titled 'First Name', and address in a column titled 'Residence Location' for all employees.
drop view if exists practiceQuery51;
create view practiceQuery51 as 
select lname as 'Last Name', fname as 'First Name', address as 'Residence Location' from employee;

-- practiceQuery52: Concatenate first name and last name into a single column 'Whole Name' along with the address for all employees.
drop view if exists practiceQuery52;
create view practiceQuery52 as 
select concat(fname, ' ', lname) as 'Whole Name', address from employee;

-- practiceQuery53: Retrieve department numbers for all employees.
drop view if exists practiceQuery53;
create view practiceQuery53 as 
select dno from employee;

-- practiceQuery54: Retrieve distinct department numbers from the employee table.
drop view if exists practiceQuery54;
create view practiceQuery54 as 
select distinct dno from employee;

-- practiceQuery55: Retrieve salary and department number for all employees.
drop view if exists practiceQuery55;
create view practiceQuery55 as 
select salary, dno from employee;

-- practiceQuery56: Retrieve the distinct salary and department number combinations for all employees.
drop view if exists practiceQuery56;
create view practiceQuery56 as 
select distinct salary, dno from employee;

-- practiceQuery60: Retrieve the first name, last name and address of all employees in department.
drop view if exists practiceQuery60;
create view practiceQuery60 as 
select fname, lname, address from employee where dno = 5;

-- practiceQuery61: Retrieve first name, last name, and address for all employees not in department 5.
drop view if exists practiceQuery61;
create view practiceQuery61 as 
select fname, lname, address from employee where dno <> 5;

-- practiceQuery62: Retrieve first name, last name, and address for all employees with a salary greater than 30,000.
drop view if exists practiceQuery62;
create view practiceQuery62 as 
select fname, lname, address from employee where salary > 30000;

-- practiceQuery63: Retrieve first name, last name, and address for all employees either in department 5 or with a salary greater than 30,000.
drop view if exists practiceQuery63;
create view practiceQuery63 as 
select fname, lname, address from employee where dno = 5 or salary > 30000;

-- practiceQuery64: Retrieve first name, last name, and address for all employees in department 5 with a salary greater than 30,000.
drop view if exists practiceQuery64;
create view practiceQuery64 as 
select fname, lname, address from employee where dno = 5 and salary > 30000;

-- practiceQuery65: Retrieve the first name, last name, address and birthdate of all employees born after January 1st, 1968.
drop view if exists practiceQuery65;
create view practiceQuery65 as 
select fname, lname, address, bdate from employee where bdate > '1968-01-01';

-- practiceQuery66: Retrieve the first name, last name, address and birthdate of all employees born after January 1st, 1964 and before August 10th, 1970.
drop view if exists practiceQuery66;
create view practiceQuery66 as 
select fname, lname, address, bdate from employee where bdate > '1964-01-01' and bdate < '1970-08-10';

-- practiceQuery67: Retrieve the first name, last name, and address of all employees, ordered by first name.
drop view if exists practiceQuery67;
create view practiceQuery67 as 
select fname, lname, address from employee order by fname;

-- practiceQuery68: Retrieve the first name, last name and address of all employees in descending last name order.
drop view if exists practiceQuery68;
create view practiceQuery68 as 
select fname, lname, address from employee order by lname desc;

-- practiceQuery69: Retrieve the first name and address of all employees, ordered by last name in descending order.
drop view if exists practiceQuery69;
create view practiceQuery69 as 
select fname, address from employee order by lname desc;

-- practiceQuery70: Retrieve the first name, last name and address of all employees in the order of last name and then first name.
drop view if exists practiceQuery70;
create view practiceQuery70 as 
select fname, lname, address from employee order by lname, fname;

-- practiceQuery71: Retrieve the first name, last name and address of all employees who live in Houston.
drop view if exists practiceQuery71;
create view practiceQuery71 as 
select fname, lname, address from employee where address like '%Houston%';

-- practiceQuery72: Retrieve the first name, last name, and address of all employees whose address contains 'Dallas'.
drop view if exists practiceQuery72;
create view practiceQuery72 as 
select fname, lname, address from employee where address like '%Dallas%';

-- practiceQuery73: Retrieve the first name, last name, and address of all employees whose first name starts with 'J'.
drop view if exists practiceQuery73;
create view practiceQuery73 as 
select fname, lname, address from employee where fname like 'J%';

-- practiceQuery74: Retrieve the first name, last name and address of all employees whose last names contain the pattern 'aya'.
drop view if exists practiceQuery74;
create view practiceQuery74 as 
select fname, lname, address from employee where lname like '%aya%';

-- practiceQuery75: Retrieve the first name, last name and address of all employees whose last  names contain the pattern 'aya' where the pattern is not at the end of the string.
drop view if exists practiceQuery75;
create view practiceQuery75 as 
select fname, lname, address from employee where lname like '%aya_%';

-- practiceQuery80: Retrieve the first name, last name, and salary with a 10% raise as 'raise' for all employees in department 5.
drop view if exists practiceQuery80;
create view practiceQuery80 as 
select fname, lname, salary + (salary * 1/10) as 'raise' from employee where dno = 5;

-- practiceQuery81: Retrieve the sum of the salaries for all employees in department number 5.
drop view if exists practiceQuery81;
create view practiceQuery81 as 
select sum(salary) from employee where dno = 5;

-- practiceQuery82: Retrieve the smallest and largest salaries for all employees in department number 5.
drop view if exists practiceQuery82;
create view practiceQuery82 as 
select min(salary), max(salary) from employee where dno = 5;

-- practiceQuery83: Count the number of distinct salary values among all employees.
drop view if exists practiceQuery83;
create view practiceQuery83 as 
select count(distinct salary) from employee;

-- practiceQuery84: Count the number of distinct supervisor SSNs among all employees.
drop view if exists practiceQuery84;
create view practiceQuery84 as 
select count(distinct superssn) from employee;

-- practiceQuery85: Retrieve the number of employees whose superssn is equal to 333445555.
drop view if exists practiceQuery85;
create view practiceQuery85 as 
select count(*) from employee where superssn = 333445555;

-- practiceQuery86: Retrieve the number of employees whose superssn is not equal to 333445555.
drop view if exists practiceQuery86;
create view practiceQuery86 as 
select count(*) from employee where superssn <> 333445555;

-- practiceQuery87: Retrieve the total count of all employees.
drop view if exists practiceQuery87;
create view practiceQuery87 as 
select count(*) from employee;

-- practiceQuery88: Retrieve the minimum, average, and maximum salary along with the department number for each department.
drop view if exists practiceQuery88;
create view practiceQuery88 as 
select dno, min(salary), avg(salary), max(salary) from employee group by dno;

-- practiceQuery89: Retrieve the minimum, average and maximum salary for the employees in each department with less than four employees.
drop view if exists practiceQuery89;
create view practiceQuery89 as 
select dno, min(salary), avg(salary), max(salary) from employee group by dno having count(*) < 4;

-- practiceQuery100: Count the number of employees earning more than $25,000 in each department.
drop view if exists practiceQuery100;
create view practiceQuery100 as 
select dno, count(*) from employee where salary > 25000 group by dno;

-- practiceQuery101: Retrieve the total number of employees whose salaries exceed $25,000 in all of the departments except Headquarters.
drop view if exists practiceQuery101;
create view practiceQuery101 as 
select dno, count(*) from employee where salary > 25000 and dno not in
(select dnumber from department where dname = 'Headquarters') group by dno;

-- practiceQuery102: Retrieve department numbers where the total number of employees is less than four.
drop view if exists practiceQuery102;
create view practiceQuery102 as 
select dno from employee group by dno having count(*) < 4;

-- practiceQuery103: Retrieve the total number of employees whose salaries exceed $25,000 per department, but only for departments where fewer than four employees work.
drop view if exists practiceQuery103;
create view practiceQuery103 as 
select dno, count(*) from employee where salary > 25000
and dno in (select dno from employee group by dno having count(*) < 4)
group by dno;

-- practiceQuery104: Retrieve the first name, last name and address for each employee that has a dependent daughter.
drop view if exists practiceQuery104;
create view practiceQuery104 as 
select fname, lname, address from employee where ssn in
(select essn from dependent where relationship = 'Daughter');

-- practiceQuery105: Retrieve the first name, last name and address for each employee that is working on a project that is located in Houston.
drop view if exists practiceQuery105;
create view practiceQuery105 as 
select fname, lname, address from employee where ssn in
(select essn from works_on where pno in
(select pnumber from project where plocation = 'Houston'));

-- practiceQuery106: Retrieve Social Security Numbers of employees who either earn more than $25,000 or work on project number 20.
drop view if exists practiceQuery106;
create view practiceQuery106 as 
(select ssn from employee where salary > 25000) union
(select essn from works_on where pno = 20);

-- practiceQuery107: Retrieve Social Security Numbers of employees who earn more than $25,000 and work on project number 20.
drop view if exists practiceQuery107;
create view practiceQuery107 as 
select ssn from employee where salary > 25000 and ssn in
(select essn from works_on where pno = 20);

-- practiceQuery108: Retrieve Social Security Numbers of employees who earn more than $25,000 but do not work on project number 20.
drop view if exists practiceQuery108;
create view practiceQuery108 as 
select ssn from employee where salary > 25000 and ssn not in
(select essn from works_on where pno = 20);

-- practiceQuery120: Retrieve all attributes for each employee and the department for which he or she works.
drop view if exists practiceQuery120;
create view practiceQuery120 as 
select fname, lname, address, dno, dnumber, dname from employee, department;

-- practiceQuery121: Display the first name, last name, address, department name, and department number for all combinations of the employee and department record sets.
drop view if exists practiceQuery121;
create view practiceQuery121 as 
select fname, lname, address, dname, dno from employee, department where dno = dnumber;

-- practiceQuery122: Retrieve the first name, last name, address, department name and department number of all employees.
drop view if exists practiceQuery122;
create view practiceQuery122 as 
select fname, lname, address, dname, dno from employee join department on dno = dnumber;

-- practiceQuery123: Match employees with departments based on natural join on department name and department number referred to as dno in a subquery.
drop view if exists practiceQuery123;
create view practiceQuery123 as 
select fname, lname, address, dname, dno from employee natural join
(select dname, dnumber as dno from department) as temp;

-- practiceQuery124: Retrieve the employee's first and last name and address, along with their supervisor's Social Security Number, first and last names for all employees.
drop view if exists practiceQuery124;
create view practiceQuery124 as 
select worker.fname as work_fname, worker.lname as work_lname, worker.address, worker.superssn, supervisor.fname, supervisor.lname
from employee as worker left outer join employee as supervisor on worker.superssn = supervisor.ssn;

-- practiceQuery125: Retrieve the name and birthdate of all dependents, along with the first and last name of their sponsor (employee). Include the names of all employees in your response, to include the first and last names of employees who don't have any dependents.
drop view if exists practiceQuery125;
create view practiceQuery125 as 
select dependent_name, dependent.bdate, fname, lname from dependent right outer join employee on essn = ssn;

-- practiceQuery126: Retrieve the first and last name, department number and department name for all department managers.
drop view if exists practiceQuery126;
create view practiceQuery126 as 
select fname, lname, dname, dnumber from employee join department on ssn = mgrssn;

-- practiceQuery127: Retrieve the first and last name, department number of all employees, along with the name of the department that they manage (if applicable).
drop view if exists practiceQuery127;
create view practiceQuery127 as 
select fname, lname, dno, dname from employee left outer join department on ssn = mgrssn;

-- practiceQuery128: Display the first and last names of employees along with the names of projects that are located in the city where they live (using the employee's address). Include the employee's address along with the project's location.
drop view if exists practiceQuery128;
create view practiceQuery128 as 
select fname, lname, address, pname, plocation from employee join project
on locate(plocation,address) > 0;

-- practiceQuery129: Find the first and last names and birthdates of the employees (supervisors included) who are old as (or older than) one or more of the department managers. Include the first and last names and birthdates of the managers as well.
drop view if exists practiceQuery129;
create view practiceQuery129 as 
select worker.fname as work_fname, worker.lname as work_lname, worker.bdate as work_bdate, supervisor.fname, supervisor.lname, supervisor.bdate
from (employee as worker) join (employee as supervisor) on worker.bdate < supervisor.bdate
where supervisor.ssn in (select mgrssn from department);

-- -------------------------------------------------
-- PUT ALL PROPOSED QUERY SOLUTIONS ABOVE THIS LINE
-- -------------------------------------------------

-- The sole purpose of the following instruction is to minimize the impact of student-entered code
-- on the remainder of the autograding processes below
set @unused_variable_dont_care_about_value = 0;

-- -----------------------------------------------
-- table data
-- -----------------------------------------------

insert into employee values
('John', 'Smith', 123456789, '1965-01-09', '731 Fondren, Houston TX', 'M', 30000, 333445555, 5),
('Franklin', 'Wong', 333445555, '1955-12-08', '638 Voss, Houston TX', 'M', 40000, 888665555, 5),
('Joyce', 'English', 453453453, '1972-07-31', '5631 Rice, Houston TX', 'F', 25000, 333445555, 5),
('Ramesh', 'Narayan', 666884444, '1962-09-15', '975 Fire Oak, Humble TX', 'M', 38000, 333445555, 5),
('James', 'Borg', 888665555, '1937-11-10', '450 Stone, Houston TX', 'M', 55000, null, 1),
('Jennifer', 'Wallace', 987654321, '1941-06-20', '291 Berry, Bellaire TX', 'F', 43000, 888665555, 4),
('Ahmad', 'Jabbar', 987987987, '1969-03-29', '980 Dallas, Houston TX', 'M', 25000, 987654321, 4),
('Alicia', 'Zelaya', 999887777, '1968-01-19', '3321 Castle, Spring TX', 'F', 25000, 987654321, 4);

insert into dependent values
(123456789, 'Alice', 'F', '1988-12-30', 'Daughter'),
(123456789, 'Elizabeth', 'F', '1967-05-05', 'Spouse'),
(123456789, 'Michael', 'M', '1988-01-04', 'Son'),
(333445555, 'Alice', 'F', '1986-04-04', 'Daughter'),
(333445555, 'Joy', 'F', '1958-05-03', 'Spouse'),
(333445555, 'Theodore', 'M', '1983-10-25', 'Son'),
(987654321, 'Abner', 'M', '1942-02-28', 'Spouse');

insert into department values
('Headquarters', 1, 888665555, '1981-06-19'),
('Administration', 4, 987654321, '1995-01-01'),
('Research', 5, 333445555, '1988-05-22');

insert into dept_locations values
(1, 'Houston'),
(4, 'Stafford'),
(5, 'Bellaire'),
(5, 'Houston'),
(5, 'Sugarland');

insert into project values
('ProductX', 1, 'Bellaire', 5),
('ProductY', 2, 'Sugarland', 5),
('ProductZ', 3, 'Houston', 5),
('Computerization', 10, 'Stafford', 4),
('Reorganization', 20, 'Houston', 1),
('Newbenefits', 30, 'Stafford', 4);

insert into works_on values
(123456789, 1, 32.5),
(123456789, 2, 7.5),
(333445555, 2, 10.0),
(333445555, 3, 10.0),
(333445555, 10, 10.0),
(333445555, 20, 10.0),
(453453453, 1, 20.0),
(453453453, 2, 20.0),
(666884444, 3, 40.0),
(888665555, 20, null),
(987654321, 20, 15.0),
(987654321, 30, 20.0),
(987987987, 10, 35.0),
(987987987, 30, 5.0),
(999887777, 10, 10.0),
(999887777, 30, 30.0);

-- -------------------------------------------------
-- database state management
-- -------------------------------------------------

create table magic44_database_state (
  state_id integer not null,
  state_description varchar(2000) default null,
  primary key (state_id)
) engine = innodb;

insert into magic44_database_state values
(0,'initial/original state'),
(1,'deleted department 4'),
(2,'deleted department 5'),
(3,'add new department 9'),
(4,'random value perturbations');

create table magic44_state_holds_rows (
  state_id integer not null,
  row_id varchar(100) not null,
  primary key (state_id, row_id)
) engine = innodb;

insert into magic44_state_holds_rows values
(0,'department_1'),
(0,'department_2'),
(0,'department_3'),
(0,'dependent_1'),
(0,'dependent_2'),
(0,'dependent_3'),
(0,'dependent_4'),
(0,'dependent_5'),
(0,'dependent_6'),
(0,'dependent_7'),
(0,'dept_locations_1'),
(0,'dept_locations_2'),
(0,'dept_locations_3'),
(0,'dept_locations_4'),
(0,'dept_locations_5'),
(0,'employee_1'),
(0,'employee_2'),
(0,'employee_3'),
(0,'employee_4'),
(0,'employee_5'),
(0,'employee_6'),
(0,'employee_7'),
(0,'employee_8'),
(0,'project_1'),
(0,'project_2'),
(0,'project_3'),
(0,'project_4'),
(0,'project_5'),
(0,'project_6'),
(0,'works_on_1'),
(0,'works_on_10'),
(0,'works_on_11'),
(0,'works_on_12'),
(0,'works_on_13'),
(0,'works_on_14'),
(0,'works_on_15'),
(0,'works_on_16'),
(0,'works_on_2'),
(0,'works_on_3'),
(0,'works_on_4'),
(0,'works_on_5'),
(0,'works_on_6'),
(0,'works_on_7'),
(0,'works_on_8'),
(0,'works_on_9'),
(1,'department_1'),
(1,'department_3'),
(1,'dependent_1'),
(1,'dependent_2'),
(1,'dependent_3'),
(1,'dependent_4'),
(1,'dependent_5'),
(1,'dependent_6'),
(1,'dept_locations_1'),
(1,'dept_locations_3'),
(1,'dept_locations_4'),
(1,'dept_locations_5'),
(1,'employee_1'),
(1,'employee_2'),
(1,'employee_3'),
(1,'employee_4'),
(1,'employee_5'),
(1,'project_1'),
(1,'project_2'),
(1,'project_3'),
(1,'project_5'),
(1,'works_on_1'),
(1,'works_on_10'),
(1,'works_on_2'),
(1,'works_on_3'),
(1,'works_on_4'),
(1,'works_on_6'),
(1,'works_on_7'),
(1,'works_on_8'),
(1,'works_on_9'),
(2,'department_1'),
(2,'department_2'),
(2,'dependent_7'),
(2,'dept_locations_1'),
(2,'dept_locations_2'),
(2,'employee_5'),
(2,'employee_6'),
(2,'employee_7'),
(2,'employee_8'),
(2,'project_4'),
(2,'project_5'),
(2,'project_6'),
(2,'works_on_10'),
(2,'works_on_11'),
(2,'works_on_12'),
(2,'works_on_13'),
(2,'works_on_14'),
(2,'works_on_15'),
(2,'works_on_16'),
(3,'department_1'),
(3,'department_2'),
(3,'department_3'),
(3,'department_4'),
(3,'dependent_1'),
(3,'dependent_10'),
(3,'dependent_2'),
(3,'dependent_3'),
(3,'dependent_4'),
(3,'dependent_5'),
(3,'dependent_6'),
(3,'dependent_7'),
(3,'dependent_9'),
(3,'dept_location_6'),
(3,'dept_location_7'),
(3,'dept_locations_1'),
(3,'dept_locations_2'),
(3,'dept_locations_3'),
(3,'dept_locations_4'),
(3,'dept_locations_5'),
(3,'employee_1'),
(3,'employee_10'),
(3,'employee_11'),
(3,'employee_12'),
(3,'employee_13'),
(3,'employee_2'),
(3,'employee_3'),
(3,'employee_4'),
(3,'employee_5'),
(3,'employee_6'),
(3,'employee_7'),
(3,'employee_8'),
(3,'employee_9'),
(3,'project_1'),
(3,'project_12'),
(3,'project_2'),
(3,'project_3'),
(3,'project_4'),
(3,'project_5'),
(3,'project_6'),
(3,'works_on_1'),
(3,'works_on_10'),
(3,'works_on_11'),
(3,'works_on_12'),
(3,'works_on_13'),
(3,'works_on_14'),
(3,'works_on_15'),
(3,'works_on_16'),
(3,'works_on_2'),
(3,'works_on_3'),
(3,'works_on_36'),
(3,'works_on_37'),
(3,'works_on_38'),
(3,'works_on_4'),
(3,'works_on_5'),
(3,'works_on_6'),
(3,'works_on_7'),
(3,'works_on_8'),
(3,'works_on_9'),
(4,'department_1'),
(4,'department_2'),
(4,'department_3'),
(4,'dependent_1'),
(4,'dependent_2'),
(4,'dependent_3'),
(4,'dependent_4'),
(4,'dependent_5'),
(4,'dependent_6'),
(4,'dependent_7'),
(4,'dept_locations_1'),
(4,'dept_locations_2'),
(4,'dept_locations_3'),
(4,'dept_locations_4'),
(4,'dept_locations_5'),
(4,'employee_16'),
(4,'employee_17'),
(4,'employee_18'),
(4,'employee_19'),
(4,'employee_20'),
(4,'employee_3'),
(4,'employee_4'),
(4,'employee_5'),
(4,'project_1'),
(4,'project_2'),
(4,'project_3'),
(4,'project_4'),
(4,'project_5'),
(4,'project_6'),
(4,'works_on_10'),
(4,'works_on_14'),
(4,'works_on_15'),
(4,'works_on_39'),
(4,'works_on_40'),
(4,'works_on_41'),
(4,'works_on_42'),
(4,'works_on_43'),
(4,'works_on_44'),
(4,'works_on_45'),
(4,'works_on_46'),
(4,'works_on_47'),
(4,'works_on_48'),
(4,'works_on_49'),
(4,'works_on_50'),
(4,'works_on_6');

create table magic44_employee_datastore (
  fname char(10) not null,
  lname char(20) not null,
  ssn decimal(9, 0) not null,
  bdate date not null,
  address char(30) not null,
  sex char(1) not null,
  salary decimal(5, 0) not null,
  superssn decimal(9, 0) default null,
  dno decimal(1, 0) not null,
  row_id varchar(100) default null,
  auto_id integer not null auto_increment,
  primary key (auto_id)
) engine = innodb;

insert into magic44_employee_datastore values
('John','Smith',123456789,'1965-01-09','731 Fondren, Houston TX','M',30000,333445555,5,'employee_1',1),
('Franklin','Wong',333445555,'1955-12-08','638 Voss, Houston TX','M',40000,888665555,5,'employee_2',2),
('Joyce','English',453453453,'1972-07-31','5631 Rice, Houston TX','F',25000,333445555,5,'employee_3',3),
('Ramesh','Narayan',666884444,'1962-09-15','975 Fire Oak, Humble TX','M',38000,333445555,5,'employee_4',4),
('James','Borg',888665555,'1937-11-10','450 Stone, Houston TX','M',55000,null,1,'employee_5',5),
('Jennifer','Wallace',987654321,'1941-06-20','291 Berry, Bellaire TX','F',43000,888665555,4,'employee_6',6),
('Ahmad','Jabbar',987987987,'1969-03-29','980 Dallas, Houston TX','M',25000,987654321,4,'employee_7',7),
('Alicia','Zelaya',999887777,'1968-01-19','3321 Castle, Spring TX','F',25000,987654321,4,'employee_8',8),
('Camila','Jackson',163479608,'1975-04-20','3830 Stellar Fruit, Tulsa OK','F',37000,235711131,9,'employee_9',9),
('Hector','Cuevas',235711131,'1970-11-06','107 Five Finger Way, Dallas TX','M',31000,888665555,9,'employee_10',10),
('Heike','Weiss',378990405,'1966-11-13','219 Zoo Palast, Norman OK','F',41000,235711131,9,'employee_11',11),
('Hiroto','Watanabe',510176317,'1961-11-17','606 Spring Tail, Houston TX','M',38000,235711131,9,'employee_12',12),
('Alicia','Smith',701294005,'1967-03-19','2 Teleport, Dallas TX','F',51000,235711131,9,'employee_13',13),
('John','Smith',123456789,'1965-01-09','731 Fondren, Houston TX','M',36000,333445555,5,'employee_16',16),
('Franklin','Wong',333445555,'1955-12-08','638 Voss, Houston TX','M',37000,888665555,5,'employee_17',17),
('Jennifer','Wallace',987654321,'1941-06-20','291 Berry, Bellaire TX','F',46000,888665555,4,'employee_18',18),
('Ahmad','Jabbar',987987987,'1969-03-29','980 Dallas, Houston TX','M',34000,987654321,4,'employee_19',19),
('Alicia','Zelaya',999887777,'1968-01-19','3321 Castle, Spring TX','F',31000,987654321,4,'employee_20',20);

create table magic44_dependent_datastore (
  essn decimal(9, 0) not null,
  dependent_name char(10) not null,
  sex char(1) not null,
  bdate date not null,
  relationship char(30) not null,
  row_id varchar(100) default null,
  auto_id integer not null auto_increment,
  primary key (auto_id)
) engine = innodb;

insert into magic44_dependent_datastore values
(123456789,'Alice','F','1988-12-30','Daughter','dependent_1',1),
(123456789,'Elizabeth','F','1967-05-05','Spouse','dependent_2',2),
(123456789,'Michael','M','1988-01-04','Son','dependent_3',3),
(333445555,'Alice','F','1986-04-04','Daughter','dependent_4',4),
(333445555,'Joy','F','1958-05-03','Spouse','dependent_5',5),
(333445555,'Theodore','M','1983-10-25','Son','dependent_6',6),
(987654321,'Abner','M','1942-02-28','Spouse','dependent_7',7),
(999887777,'Aurora','F','2010-01-01','Daughter','dependent_8',8),
(378990405,'Ariel','M','1989-05-25','Son','dependent_9',9),
(378990405,'Florence','F','1966-01-25','Spouse','dependent_10',10);

create table magic44_department_datastore (
  dname char(20) not null,
  dnumber decimal(1, 0) not null,
  mgrssn decimal(9, 0) not null,
  mgrstartdate date not null,
  row_id varchar(100) default null,
  auto_id integer not null auto_increment,
  primary key (auto_id)
) engine = innodb;

insert into magic44_department_datastore values
('Headquarters',1,888665555,'1981-06-19','department_1',1),
('Administration',4,987654321,'1995-01-01','department_2',2),
('Research',5,333445555,'1988-05-22','department_3',3),
('Reverse Engineering',9,235711131,'2002-06-22','department_4',4);

create table magic44_dept_locations_datastore (
  dnumber decimal(1, 0) not null,
  dlocation char(15) not null,
  row_id varchar(100) default null,
  auto_id integer not null auto_increment,
  primary key (auto_id)
) engine = innodb;

insert into magic44_dept_locations_datastore values
(1,'Houston','dept_locations_1',1),
(4,'Stafford','dept_locations_2',2),
(5,'Bellaire','dept_locations_3',3),
(5,'Houston','dept_locations_4',4),
(5,'Sugarland','dept_locations_5',5),
(9,'Dallas','dept_location_6',6),
(9,'Sugarland','dept_location_7',7);

create table magic44_project_datastore (
  pname char(20) not null,
  pnumber decimal(2, 0) not null,
  plocation char(20) not null,
  dnum decimal(1, 0) not null,
  row_id varchar(100) default null,
  auto_id integer not null auto_increment,
  primary key (auto_id)
) engine = innodb;

insert into magic44_project_datastore values
('ProductX',1,'Bellaire',5,'project_1',1),
('ProductY',2,'Sugarland',5,'project_2',2),
('ProductZ',3,'Houston',5,'project_3',3),
('Computerization',10,'Stafford',4,'project_4',4),
('Reorganization',20,'Houston',1,'project_5',5),
('Newbenefits',30,'Stafford',4,'project_6',6),
('Special',41,'Stafford',4,'project_8',8),
('Community',43,'Amarillo',5,'project_9',9),
('WrongPlace',55,'Bellaire',4,'project_10',10),
('WrongDept',66,'Amarillo',1,'project_11',11),
('Hindsight',55,'Dallas',9,'project_12',12);

create table magic44_works_on_datastore (
  essn decimal(9, 0) not null,
  pno decimal(2, 0) not null,
  hours decimal(5, 1) default null,
  row_id varchar(100) default null,
  auto_id integer not null auto_increment,
  primary key (auto_id)
) engine = innodb;

insert into magic44_works_on_datastore values
(123456789,1,32.5,'works_on_1',1),
(123456789,2,7.5,'works_on_2',2),
(333445555,2,10.0,'works_on_3',3),
(333445555,3,10.0,'works_on_4',4),
(333445555,10,10.0,'works_on_5',5),
(333445555,20,10.0,'works_on_6',6),
(453453453,1,20.0,'works_on_7',7),
(453453453,2,20.0,'works_on_8',8),
(666884444,3,40.0,'works_on_9',9),
(888665555,20,null,'works_on_10',10),
(987654321,20,15.0,'works_on_11',11),
(987654321,30,20.0,'works_on_12',12),
(987987987,10,35.0,'works_on_13',13),
(987987987,30,5.0,'works_on_14',14),
(999887777,10,10.0,'works_on_15',15),
(999887777,30,30.0,'works_on_16',16),
(123456789,41,99.0,'works_on_32',32),
(333445555,41,99.0,'works_on_33',33),
(333445555,43,99.0,'works_on_34',34),
(987654321,41,99.0,'works_on_35',35),
(163479608,55,35.0,'works_on_36',36),
(235711131,55,10.0,'works_on_37',37),
(701294005,55,20.0,'works_on_38',38),
(123456789,1,44.5,'works_on_39',39),
(123456789,2,9.0,'works_on_40',40),
(333445555,2,11.5,'works_on_41',41),
(333445555,3,14.5,'works_on_42',42),
(333445555,10,13.0,'works_on_43',43),
(453453453,1,30.5,'works_on_44',44),
(453453453,2,27.5,'works_on_45',45),
(666884444,3,49.0,'works_on_46',46),
(987654321,20,27.0,'works_on_47',47),
(987654321,30,24.5,'works_on_48',48),
(987987987,10,41.0,'works_on_49',49),
(999887777,30,31.5,'works_on_50',50);

-- -------------------------------------------------
-- allow controlled changes to the database state
-- -------------------------------------------------

drop procedure if exists magic44_set_database_state;
delimiter //
create procedure magic44_set_database_state (in requestedState integer)
begin
	-- Purge and then reload all of the database rows back into the tables.
    -- Ensure that the data is deleted in reverse order with respect to the
    -- foreign key dependencies (i.e., from children up to parents).
	delete from dept_locations;
	delete from works_on;
	delete from dependent;
	delete from project;
	delete from department;
	delete from employee;
    
    -- Check the validity of the requested state
    if exists(select * from magic44_state_holds_rows where state_id = requestedState) then
		set @trueState = requestedState;
	else
		set @trueState = 0;
	end if;

    -- Ensure that the data is inserted in order with respect to the foreign
    -- key dependencies (i.e., from parents down to children)
    insert into employee (select fname, lname, ssn, bdate, address, sex, salary,
		superssn, dno from magic44_employee_datastore where row_id in
        (select row_id from magic44_state_holds_rows where state_id = @trueState));
	insert into dependent (select essn, dependent_name, sex, bdate, relationship
		from magic44_dependent_datastore where row_id in
        (select row_id from magic44_state_holds_rows where state_id = @trueState));
	insert into department (select dname, dnumber, mgrssn, mgrstartdate
		from magic44_department_datastore where row_id in
        (select row_id from magic44_state_holds_rows where state_id = @trueState));
	insert into dept_locations (select dnumber, dlocation
		from magic44_dept_locations_datastore where row_id in
        (select row_id from magic44_state_holds_rows where state_id = @trueState));
	insert into project (select pname, pnumber, plocation, dnum
		from magic44_project_datastore where row_id in
        (select row_id from magic44_state_holds_rows where state_id = @trueState));
	insert into works_on (select essn, pno, hours
		from magic44_works_on_datastore where row_id in
        (select row_id from magic44_state_holds_rows where state_id = @trueState));
end //
delimiter ;

-- -------------------------------------------------
-- expected answers for autograding comparisons
-- -------------------------------------------------

-- These tables are used to store the answers and test results.  The answers are generated by executing
-- the test script against our reference solution.  The test results are collected by running the test
-- script against your submission in order to compare the results.

-- the results from magic44_data_capture the are transferred into the magic44_test_results table
drop table if exists magic44_test_results;
create table magic44_test_results (
	state_id integer not null,
    query_id integer,
	row_hash varchar(2000) not null
);

-- the answers generated from the reference solution are loaded below
drop table if exists magic44_expected_results;
create table magic44_expected_results (
	state_id integer not null,
    query_id integer,
	row_hash varchar(2000) not null
);

insert into magic44_expected_results values
(0,0,'result#set#exists############'),
(0,1,'result#set#exists############'),
(0,2,'result#set#exists############'),
(0,3,'result#set#exists############'),
(0,4,'result#set#exists############'),
(0,5,'result#set#exists############'),
(0,6,'result#set#exists############'),
(0,7,'result#set#exists############'),
(0,8,'result#set#exists############'),
(0,9,'result#set#exists############'),
(0,10,'result#set#exists############'),
(0,11,'result#set#exists############'),
(0,12,'result#set#exists############'),
(0,13,'result#set#exists############'),
(0,14,'result#set#exists############'),
(0,15,'result#set#exists############'),
(0,16,'result#set#exists############'),
(0,17,'result#set#exists############'),
(0,18,'result#set#exists############'),
(0,19,'result#set#exists############'),
(0,20,'result#set#exists############'),
(0,21,'result#set#exists############'),
(0,22,'result#set#exists############'),
(0,23,'result#set#exists############'),
(0,24,'result#set#exists############'),
(0,25,'result#set#exists############'),
(0,26,'result#set#exists############'),
(0,27,'result#set#exists############'),
(0,28,'result#set#exists############'),
(0,29,'result#set#exists############'),
(0,30,'result#set#exists############'),
(0,31,'result#set#exists############'),
(0,32,'result#set#exists############'),
(0,33,'result#set#exists############'),
(0,34,'result#set#exists############'),
(0,35,'result#set#exists############'),
(0,36,'result#set#exists############'),
(0,37,'result#set#exists############'),
(0,40,'result#set#exists############'),
(0,41,'result#set#exists############'),
(0,42,'result#set#exists############'),
(0,43,'result#set#exists############'),
(0,44,'result#set#exists############'),
(0,50,'result#set#exists############'),
(0,51,'result#set#exists############'),
(0,52,'result#set#exists############'),
(0,53,'result#set#exists############'),
(0,54,'result#set#exists############'),
(0,55,'result#set#exists############'),
(0,56,'result#set#exists############'),
(0,60,'result#set#exists############'),
(0,61,'result#set#exists############'),
(0,62,'result#set#exists############'),
(0,63,'result#set#exists############'),
(0,64,'result#set#exists############'),
(0,65,'result#set#exists############'),
(0,66,'result#set#exists############'),
(0,67,'result#set#exists############'),
(0,68,'result#set#exists############'),
(0,69,'result#set#exists############'),
(0,70,'result#set#exists############'),
(0,71,'result#set#exists############'),
(0,72,'result#set#exists############'),
(0,73,'result#set#exists############'),
(0,74,'result#set#exists############'),
(0,75,'result#set#exists############'),
(0,80,'result#set#exists############'),
(0,81,'result#set#exists############'),
(0,82,'result#set#exists############'),
(0,83,'result#set#exists############'),
(0,84,'result#set#exists############'),
(0,85,'result#set#exists############'),
(0,86,'result#set#exists############'),
(0,87,'result#set#exists############'),
(0,88,'result#set#exists############'),
(0,89,'result#set#exists############'),
(0,100,'result#set#exists############'),
(0,101,'result#set#exists############'),
(0,102,'result#set#exists############'),
(0,103,'result#set#exists############'),
(0,104,'result#set#exists############'),
(0,105,'result#set#exists############'),
(0,106,'result#set#exists############'),
(0,107,'result#set#exists############'),
(0,108,'result#set#exists############'),
(0,120,'result#set#exists############'),
(0,121,'result#set#exists############'),
(0,122,'result#set#exists############'),
(0,123,'result#set#exists############'),
(0,124,'result#set#exists############'),
(0,125,'result#set#exists############'),
(0,126,'result#set#exists############'),
(0,127,'result#set#exists############'),
(0,128,'result#set#exists############'),
(0,129,'result#set#exists############'),
(1,0,'result#set#exists############'),
(1,1,'result#set#exists############'),
(1,2,'result#set#exists############'),
(1,3,'result#set#exists############'),
(1,4,'result#set#exists############'),
(1,5,'result#set#exists############'),
(1,6,'result#set#exists############'),
(1,7,'result#set#exists############'),
(1,8,'result#set#exists############'),
(1,9,'result#set#exists############'),
(1,10,'result#set#exists############'),
(1,11,'result#set#exists############'),
(1,12,'result#set#exists############'),
(1,13,'result#set#exists############'),
(1,14,'result#set#exists############'),
(1,15,'result#set#exists############'),
(1,16,'result#set#exists############'),
(1,17,'result#set#exists############'),
(1,18,'result#set#exists############'),
(1,19,'result#set#exists############'),
(1,20,'result#set#exists############'),
(1,21,'result#set#exists############'),
(1,22,'result#set#exists############'),
(1,23,'result#set#exists############'),
(1,24,'result#set#exists############'),
(1,25,'result#set#exists############'),
(1,26,'result#set#exists############'),
(1,27,'result#set#exists############'),
(1,28,'result#set#exists############'),
(1,29,'result#set#exists############'),
(1,30,'result#set#exists############'),
(1,31,'result#set#exists############'),
(1,32,'result#set#exists############'),
(1,33,'result#set#exists############'),
(1,34,'result#set#exists############'),
(1,35,'result#set#exists############'),
(1,36,'result#set#exists############'),
(1,37,'result#set#exists############'),
(1,40,'result#set#exists############'),
(1,41,'result#set#exists############'),
(1,42,'result#set#exists############'),
(1,43,'result#set#exists############'),
(1,44,'result#set#exists############'),
(1,50,'result#set#exists############'),
(1,51,'result#set#exists############'),
(1,52,'result#set#exists############'),
(1,53,'result#set#exists############'),
(1,54,'result#set#exists############'),
(1,55,'result#set#exists############'),
(1,56,'result#set#exists############'),
(1,60,'result#set#exists############'),
(1,61,'result#set#exists############'),
(1,62,'result#set#exists############'),
(1,63,'result#set#exists############'),
(1,64,'result#set#exists############'),
(1,65,'result#set#exists############'),
(1,66,'result#set#exists############'),
(1,67,'result#set#exists############'),
(1,68,'result#set#exists############'),
(1,69,'result#set#exists############'),
(1,70,'result#set#exists############'),
(1,71,'result#set#exists############'),
(1,72,'result#set#exists############'),
(1,73,'result#set#exists############'),
(1,74,'result#set#exists############'),
(1,75,'result#set#exists############'),
(1,80,'result#set#exists############'),
(1,81,'result#set#exists############'),
(1,82,'result#set#exists############'),
(1,83,'result#set#exists############'),
(1,84,'result#set#exists############'),
(1,85,'result#set#exists############'),
(1,86,'result#set#exists############'),
(1,87,'result#set#exists############'),
(1,88,'result#set#exists############'),
(1,89,'result#set#exists############'),
(1,100,'result#set#exists############'),
(1,101,'result#set#exists############'),
(1,102,'result#set#exists############'),
(1,103,'result#set#exists############'),
(1,104,'result#set#exists############'),
(1,105,'result#set#exists############'),
(1,106,'result#set#exists############'),
(1,107,'result#set#exists############'),
(1,108,'result#set#exists############'),
(1,120,'result#set#exists############'),
(1,121,'result#set#exists############'),
(1,122,'result#set#exists############'),
(1,123,'result#set#exists############'),
(1,124,'result#set#exists############'),
(1,125,'result#set#exists############'),
(1,126,'result#set#exists############'),
(1,127,'result#set#exists############'),
(1,128,'result#set#exists############'),
(1,129,'result#set#exists############'),
(2,0,'result#set#exists############'),
(2,1,'result#set#exists############'),
(2,2,'result#set#exists############'),
(2,3,'result#set#exists############'),
(2,4,'result#set#exists############'),
(2,5,'result#set#exists############'),
(2,6,'result#set#exists############'),
(2,7,'result#set#exists############'),
(2,8,'result#set#exists############'),
(2,9,'result#set#exists############'),
(2,10,'result#set#exists############'),
(2,11,'result#set#exists############'),
(2,12,'result#set#exists############'),
(2,13,'result#set#exists############'),
(2,14,'result#set#exists############'),
(2,15,'result#set#exists############'),
(2,16,'result#set#exists############'),
(2,17,'result#set#exists############'),
(2,18,'result#set#exists############'),
(2,19,'result#set#exists############'),
(2,20,'result#set#exists############'),
(2,21,'result#set#exists############'),
(2,22,'result#set#exists############'),
(2,23,'result#set#exists############'),
(2,24,'result#set#exists############'),
(2,25,'result#set#exists############'),
(2,26,'result#set#exists############'),
(2,27,'result#set#exists############'),
(2,28,'result#set#exists############'),
(2,29,'result#set#exists############'),
(2,30,'result#set#exists############'),
(2,31,'result#set#exists############'),
(2,32,'result#set#exists############'),
(2,33,'result#set#exists############'),
(2,34,'result#set#exists############'),
(2,35,'result#set#exists############'),
(2,36,'result#set#exists############'),
(2,37,'result#set#exists############'),
(2,40,'result#set#exists############'),
(2,41,'result#set#exists############'),
(2,42,'result#set#exists############'),
(2,43,'result#set#exists############'),
(2,44,'result#set#exists############'),
(2,50,'result#set#exists############'),
(2,51,'result#set#exists############'),
(2,52,'result#set#exists############'),
(2,53,'result#set#exists############'),
(2,54,'result#set#exists############'),
(2,55,'result#set#exists############'),
(2,56,'result#set#exists############'),
(2,60,'result#set#exists############'),
(2,61,'result#set#exists############'),
(2,62,'result#set#exists############'),
(2,63,'result#set#exists############'),
(2,64,'result#set#exists############'),
(2,65,'result#set#exists############'),
(2,66,'result#set#exists############'),
(2,67,'result#set#exists############'),
(2,68,'result#set#exists############'),
(2,69,'result#set#exists############'),
(2,70,'result#set#exists############'),
(2,71,'result#set#exists############'),
(2,72,'result#set#exists############'),
(2,73,'result#set#exists############'),
(2,74,'result#set#exists############'),
(2,75,'result#set#exists############'),
(2,80,'result#set#exists############'),
(2,81,'result#set#exists############'),
(2,82,'result#set#exists############'),
(2,83,'result#set#exists############'),
(2,84,'result#set#exists############'),
(2,85,'result#set#exists############'),
(2,86,'result#set#exists############'),
(2,87,'result#set#exists############'),
(2,88,'result#set#exists############'),
(2,89,'result#set#exists############'),
(2,100,'result#set#exists############'),
(2,101,'result#set#exists############'),
(2,102,'result#set#exists############'),
(2,103,'result#set#exists############'),
(2,104,'result#set#exists############'),
(2,105,'result#set#exists############'),
(2,106,'result#set#exists############'),
(2,107,'result#set#exists############'),
(2,108,'result#set#exists############'),
(2,120,'result#set#exists############'),
(2,121,'result#set#exists############'),
(2,122,'result#set#exists############'),
(2,123,'result#set#exists############'),
(2,124,'result#set#exists############'),
(2,125,'result#set#exists############'),
(2,126,'result#set#exists############'),
(2,127,'result#set#exists############'),
(2,128,'result#set#exists############'),
(2,129,'result#set#exists############'),
(3,0,'result#set#exists############'),
(3,1,'result#set#exists############'),
(3,2,'result#set#exists############'),
(3,3,'result#set#exists############'),
(3,4,'result#set#exists############'),
(3,5,'result#set#exists############'),
(3,6,'result#set#exists############'),
(3,7,'result#set#exists############'),
(3,8,'result#set#exists############'),
(3,9,'result#set#exists############'),
(3,10,'result#set#exists############'),
(3,11,'result#set#exists############'),
(3,12,'result#set#exists############'),
(3,13,'result#set#exists############'),
(3,14,'result#set#exists############'),
(3,15,'result#set#exists############'),
(3,16,'result#set#exists############'),
(3,17,'result#set#exists############'),
(3,18,'result#set#exists############'),
(3,19,'result#set#exists############'),
(3,20,'result#set#exists############'),
(3,21,'result#set#exists############'),
(3,22,'result#set#exists############'),
(3,23,'result#set#exists############'),
(3,24,'result#set#exists############'),
(3,25,'result#set#exists############'),
(3,26,'result#set#exists############'),
(3,27,'result#set#exists############'),
(3,28,'result#set#exists############'),
(3,29,'result#set#exists############'),
(3,30,'result#set#exists############'),
(3,31,'result#set#exists############'),
(3,32,'result#set#exists############'),
(3,33,'result#set#exists############'),
(3,34,'result#set#exists############'),
(3,35,'result#set#exists############'),
(3,36,'result#set#exists############'),
(3,37,'result#set#exists############'),
(3,40,'result#set#exists############'),
(3,41,'result#set#exists############'),
(3,42,'result#set#exists############'),
(3,43,'result#set#exists############'),
(3,44,'result#set#exists############'),
(3,50,'result#set#exists############'),
(3,51,'result#set#exists############'),
(3,52,'result#set#exists############'),
(3,53,'result#set#exists############'),
(3,54,'result#set#exists############'),
(3,55,'result#set#exists############'),
(3,56,'result#set#exists############'),
(3,60,'result#set#exists############'),
(3,61,'result#set#exists############'),
(3,62,'result#set#exists############'),
(3,63,'result#set#exists############'),
(3,64,'result#set#exists############'),
(3,65,'result#set#exists############'),
(3,66,'result#set#exists############'),
(3,67,'result#set#exists############'),
(3,68,'result#set#exists############'),
(3,69,'result#set#exists############'),
(3,70,'result#set#exists############'),
(3,71,'result#set#exists############'),
(3,72,'result#set#exists############'),
(3,73,'result#set#exists############'),
(3,74,'result#set#exists############'),
(3,75,'result#set#exists############'),
(3,80,'result#set#exists############'),
(3,81,'result#set#exists############'),
(3,82,'result#set#exists############'),
(3,83,'result#set#exists############'),
(3,84,'result#set#exists############'),
(3,85,'result#set#exists############'),
(3,86,'result#set#exists############'),
(3,87,'result#set#exists############'),
(3,88,'result#set#exists############'),
(3,89,'result#set#exists############'),
(3,100,'result#set#exists############'),
(3,101,'result#set#exists############'),
(3,102,'result#set#exists############'),
(3,103,'result#set#exists############'),
(3,104,'result#set#exists############'),
(3,105,'result#set#exists############'),
(3,106,'result#set#exists############'),
(3,107,'result#set#exists############'),
(3,108,'result#set#exists############'),
(3,120,'result#set#exists############'),
(3,121,'result#set#exists############'),
(3,122,'result#set#exists############'),
(3,123,'result#set#exists############'),
(3,124,'result#set#exists############'),
(3,125,'result#set#exists############'),
(3,126,'result#set#exists############'),
(3,127,'result#set#exists############'),
(3,128,'result#set#exists############'),
(3,129,'result#set#exists############'),
(4,0,'result#set#exists############'),
(4,1,'result#set#exists############'),
(4,2,'result#set#exists############'),
(4,3,'result#set#exists############'),
(4,4,'result#set#exists############'),
(4,5,'result#set#exists############'),
(4,6,'result#set#exists############'),
(4,7,'result#set#exists############'),
(4,8,'result#set#exists############'),
(4,9,'result#set#exists############'),
(4,10,'result#set#exists############'),
(4,11,'result#set#exists############'),
(4,12,'result#set#exists############'),
(4,13,'result#set#exists############'),
(4,14,'result#set#exists############'),
(4,15,'result#set#exists############'),
(4,16,'result#set#exists############'),
(4,17,'result#set#exists############'),
(4,18,'result#set#exists############'),
(4,19,'result#set#exists############'),
(4,20,'result#set#exists############'),
(4,21,'result#set#exists############'),
(4,22,'result#set#exists############'),
(4,23,'result#set#exists############'),
(4,24,'result#set#exists############'),
(4,25,'result#set#exists############'),
(4,26,'result#set#exists############'),
(4,27,'result#set#exists############'),
(4,28,'result#set#exists############'),
(4,29,'result#set#exists############'),
(4,30,'result#set#exists############'),
(4,31,'result#set#exists############'),
(4,32,'result#set#exists############'),
(4,33,'result#set#exists############'),
(4,34,'result#set#exists############'),
(4,35,'result#set#exists############'),
(4,36,'result#set#exists############'),
(4,37,'result#set#exists############'),
(4,40,'result#set#exists############'),
(4,41,'result#set#exists############'),
(4,42,'result#set#exists############'),
(4,43,'result#set#exists############'),
(4,44,'result#set#exists############'),
(4,50,'result#set#exists############'),
(4,51,'result#set#exists############'),
(4,52,'result#set#exists############'),
(4,53,'result#set#exists############'),
(4,54,'result#set#exists############'),
(4,55,'result#set#exists############'),
(4,56,'result#set#exists############'),
(4,60,'result#set#exists############'),
(4,61,'result#set#exists############'),
(4,62,'result#set#exists############'),
(4,63,'result#set#exists############'),
(4,64,'result#set#exists############'),
(4,65,'result#set#exists############'),
(4,66,'result#set#exists############'),
(4,67,'result#set#exists############'),
(4,68,'result#set#exists############'),
(4,69,'result#set#exists############'),
(4,70,'result#set#exists############'),
(4,71,'result#set#exists############'),
(4,72,'result#set#exists############'),
(4,73,'result#set#exists############'),
(4,74,'result#set#exists############'),
(4,75,'result#set#exists############'),
(4,80,'result#set#exists############'),
(4,81,'result#set#exists############'),
(4,82,'result#set#exists############'),
(4,83,'result#set#exists############'),
(4,84,'result#set#exists############'),
(4,85,'result#set#exists############'),
(4,86,'result#set#exists############'),
(4,87,'result#set#exists############'),
(4,88,'result#set#exists############'),
(4,89,'result#set#exists############'),
(4,100,'result#set#exists############'),
(4,101,'result#set#exists############'),
(4,102,'result#set#exists############'),
(4,103,'result#set#exists############'),
(4,104,'result#set#exists############'),
(4,105,'result#set#exists############'),
(4,106,'result#set#exists############'),
(4,107,'result#set#exists############'),
(4,108,'result#set#exists############'),
(4,120,'result#set#exists############'),
(4,121,'result#set#exists############'),
(4,122,'result#set#exists############'),
(4,123,'result#set#exists############'),
(4,124,'result#set#exists############'),
(4,125,'result#set#exists############'),
(4,126,'result#set#exists############'),
(4,127,'result#set#exists############'),
(4,128,'result#set#exists############'),
(4,129,'result#set#exists############'),
(0,0,'1965-01-09#731fondren,houstontx#############'),
(0,1,'john#smith#731fondren,houstontx############'),
(0,1,'franklin#wong#638voss,houstontx############'),
(0,1,'joyce#english#5631rice,houstontx############'),
(0,1,'ramesh#narayan#975fireoak,humbletx############'),
(0,2,'10#4#wallace#291berry,bellairetx#1941-06-20##########'),
(0,2,'30#4#wallace#291berry,bellairetx#1941-06-20##########'),
(0,4,'1##############'),
(0,4,'2##############'),
(0,5,'john#smith#############'),
(0,5,'franklin#wong#############'),
(0,6,'joyce#english#############'),
(0,6,'ramesh#narayan#############'),
(0,6,'james#borg#############'),
(0,6,'ahmad#jabbar#############'),
(0,6,'alicia#zelaya#############'),
(0,7,'jennifer#wallace#############'),
(0,7,'franklin#wong#############'),
(0,8,'john#smith#franklin#wong###########'),
(0,8,'franklin#wong#james#borg###########'),
(0,8,'joyce#english#franklin#wong###########'),
(0,8,'ramesh#narayan#franklin#wong###########'),
(0,8,'james#borg#############'),
(0,8,'jennifer#wallace#james#borg###########'),
(0,8,'ahmad#jabbar#jennifer#wallace###########'),
(0,8,'alicia#zelaya#jennifer#wallace###########'),
(0,9,'123456789##############'),
(0,9,'333445555##############'),
(0,9,'453453453##############'),
(0,9,'666884444##############'),
(0,9,'888665555##############'),
(0,9,'987654321##############'),
(0,9,'987987987##############'),
(0,9,'999887777##############'),
(0,10,'123456789#research#############'),
(0,10,'123456789#headquarters#############'),
(0,10,'123456789#administration#############'),
(0,10,'333445555#research#############'),
(0,10,'333445555#headquarters#############'),
(0,10,'333445555#administration#############'),
(0,10,'453453453#research#############'),
(0,10,'453453453#headquarters#############'),
(0,10,'453453453#administration#############'),
(0,10,'666884444#research#############'),
(0,10,'666884444#headquarters#############'),
(0,10,'666884444#administration#############'),
(0,10,'888665555#research#############'),
(0,10,'888665555#headquarters#############'),
(0,10,'888665555#administration#############'),
(0,10,'987654321#research#############'),
(0,10,'987654321#headquarters#############'),
(0,10,'987654321#administration#############'),
(0,10,'987987987#research#############'),
(0,10,'987987987#headquarters#############'),
(0,10,'987987987#administration#############'),
(0,10,'999887777#research#############'),
(0,10,'999887777#headquarters#############'),
(0,10,'999887777#administration#############'),
(0,11,'30000##############'),
(0,11,'40000##############'),
(0,11,'25000##############'),
(0,11,'38000##############'),
(0,11,'55000##############'),
(0,11,'43000##############'),
(0,12,'john#smith#############'),
(0,12,'franklin#wong#############'),
(0,12,'joyce#english#############'),
(0,12,'james#borg#############'),
(0,12,'ahmad#jabbar#############'),
(0,13,'franklin#wong#40000.00############'),
(0,13,'ramesh#narayan#38000.00############'),
(0,13,'james#borg#55000.00############'),
(0,13,'jennifer#wallace#43000.00############'),
(0,13,'ahmad#jabbar#25000.00############'),
(0,13,'alicia#zelaya#25000.00############'),
(0,13,'john#smith#33000.00############'),
(0,13,'joyce#english#27500.00############'),
(0,14,'john#smith#123456789#1965-01-09#731fondren,houstontx#m#30000#333445555#5######'),
(0,14,'franklin#wong#333445555#1955-12-08#638voss,houstontx#m#40000#888665555#5######'),
(0,14,'ramesh#narayan#666884444#1962-09-15#975fireoak,humbletx#m#38000#333445555#5######'),
(0,15,'research#smith#john#productx###########'),
(0,15,'research#smith#john#producty###########'),
(0,15,'research#wong#franklin#producty###########'),
(0,15,'research#wong#franklin#productz###########'),
(0,15,'research#wong#franklin#computerization###########'),
(0,15,'research#wong#franklin#reorganization###########'),
(0,15,'research#english#joyce#productx###########'),
(0,15,'research#english#joyce#producty###########'),
(0,15,'research#narayan#ramesh#productz###########'),
(0,15,'headquarters#borg#james#reorganization###########'),
(0,15,'administration#wallace#jennifer#reorganization###########'),
(0,15,'administration#wallace#jennifer#newbenefits###########'),
(0,15,'administration#jabbar#ahmad#computerization###########'),
(0,15,'administration#jabbar#ahmad#newbenefits###########'),
(0,15,'administration#zelaya#alicia#computerization###########'),
(0,15,'administration#zelaya#alicia#newbenefits###########'),
(0,17,'123456789##############'),
(0,17,'333445555##############'),
(0,17,'453453453##############'),
(0,17,'666884444##############'),
(0,18,'james#borg#############'),
(0,19,'281000#55000#25000#35125.0000###########'),
(0,20,'133000#40000#25000#33250.0000###########'),
(0,21,'8##############'),
(0,22,'4##############'),
(0,23,'6##############'),
(0,24,'5#4#33250.0000############'),
(0,24,'1#1#55000.0000############'),
(0,24,'4#3#31000.0000############'),
(0,25,'10#computerization#3############'),
(0,25,'30#newbenefits#3############'),
(0,25,'1#productx#2############'),
(0,25,'2#producty#3############'),
(0,25,'3#productz#2############'),
(0,25,'20#reorganization#3############'),
(0,26,'10#computerization#3############'),
(0,26,'30#newbenefits#3############'),
(0,26,'2#producty#3############'),
(0,26,'20#reorganization#3############'),
(0,27,'10#computerization#1############'),
(0,27,'30#newbenefits#0############'),
(0,27,'1#productx#2############'),
(0,27,'2#producty#3############'),
(0,27,'3#productz#2############'),
(0,27,'20#reorganization#1############'),
(0,28,'1#1#############'),
(0,28,'4#1#############'),
(0,29,'john#smith#123456789#1965-01-09#731fondren,houstontx#m#30000#333445555#5######'),
(0,29,'franklin#wong#333445555#1955-12-08#638voss,houstontx#m#40000#888665555#5######'),
(0,29,'joyce#english#453453453#1972-07-31#5631rice,houstontx#f#25000#333445555#5######'),
(0,29,'ramesh#narayan#666884444#1962-09-15#975fireoak,humbletx#m#38000#333445555#5######'),
(0,30,'john#smith#123456789#1965-01-09#731fondren,houstontx#m#30000#333445555#5#research#5#333445555#1988-05-22##'),
(0,30,'franklin#wong#333445555#1955-12-08#638voss,houstontx#m#40000#888665555#5#research#5#333445555#1988-05-22##'),
(0,30,'joyce#english#453453453#1972-07-31#5631rice,houstontx#f#25000#333445555#5#research#5#333445555#1988-05-22##'),
(0,30,'ramesh#narayan#666884444#1962-09-15#975fireoak,humbletx#m#38000#333445555#5#research#5#333445555#1988-05-22##'),
(0,30,'james#borg#888665555#1937-11-10#450stone,houstontx#m#55000##1#headquarters#1#888665555#1981-06-19##'),
(0,30,'jennifer#wallace#987654321#1941-06-20#291berry,bellairetx#f#43000#888665555#4#administration#4#987654321#1995-01-01##'),
(0,30,'ahmad#jabbar#987987987#1969-03-29#980dallas,houstontx#m#25000#987654321#4#administration#4#987654321#1995-01-01##'),
(0,30,'alicia#zelaya#999887777#1968-01-19#3321castle,springtx#f#25000#987654321#4#administration#4#987654321#1995-01-01##'),
(0,31,'franklin#wong#1955-12-08############'),
(0,32,'john#smith#############'),
(0,32,'joyce#english#############'),
(0,34,'john#smith#############'),
(0,34,'joyce#english#############'),
(0,34,'ramesh#narayan#############'),
(0,35,'james#borg#############'),
(0,36,'john#smith#############'),
(0,36,'joyce#english#############'),
(0,36,'ramesh#narayan#############'),
(0,36,'ahmad#jabbar#############'),
(0,36,'alicia#zelaya#############'),
(0,37,'franklin#wong#############'),
(0,37,'ramesh#narayan#############'),
(0,37,'james#borg#############'),
(0,37,'jennifer#wallace#############'),
(0,40,'helloworld!##############'),
(0,41,'helloworld!##############'),
(0,42,'10##############'),
(0,43,'10#21#4############'),
(0,44,'john#smith#123456789#1965-01-09#731fondren,houstontx#m#30000#333445555#5######'),
(0,44,'franklin#wong#333445555#1955-12-08#638voss,houstontx#m#40000#888665555#5######'),
(0,44,'joyce#english#453453453#1972-07-31#5631rice,houstontx#f#25000#333445555#5######'),
(0,44,'ramesh#narayan#666884444#1962-09-15#975fireoak,humbletx#m#38000#333445555#5######'),
(0,44,'james#borg#888665555#1937-11-10#450stone,houstontx#m#55000##1######'),
(0,44,'jennifer#wallace#987654321#1941-06-20#291berry,bellairetx#f#43000#888665555#4######'),
(0,44,'ahmad#jabbar#987987987#1969-03-29#980dallas,houstontx#m#25000#987654321#4######'),
(0,44,'alicia#zelaya#999887777#1968-01-19#3321castle,springtx#f#25000#987654321#4######'),
(0,50,'john#smith#731fondren,houstontx############'),
(0,50,'franklin#wong#638voss,houstontx############'),
(0,50,'joyce#english#5631rice,houstontx############'),
(0,50,'ramesh#narayan#975fireoak,humbletx############'),
(0,50,'james#borg#450stone,houstontx############'),
(0,50,'jennifer#wallace#291berry,bellairetx############'),
(0,50,'ahmad#jabbar#980dallas,houstontx############'),
(0,50,'alicia#zelaya#3321castle,springtx############'),
(0,51,'smith#john#731fondren,houstontx############'),
(0,51,'wong#franklin#638voss,houstontx############'),
(0,51,'english#joyce#5631rice,houstontx############'),
(0,51,'narayan#ramesh#975fireoak,humbletx############'),
(0,51,'borg#james#450stone,houstontx############'),
(0,51,'wallace#jennifer#291berry,bellairetx############'),
(0,51,'jabbar#ahmad#980dallas,houstontx############'),
(0,51,'zelaya#alicia#3321castle,springtx############'),
(0,52,'johnsmith#731fondren,houstontx#############'),
(0,52,'franklinwong#638voss,houstontx#############'),
(0,52,'joyceenglish#5631rice,houstontx#############'),
(0,52,'rameshnarayan#975fireoak,humbletx#############'),
(0,52,'jamesborg#450stone,houstontx#############'),
(0,52,'jenniferwallace#291berry,bellairetx#############'),
(0,52,'ahmadjabbar#980dallas,houstontx#############'),
(0,52,'aliciazelaya#3321castle,springtx#############'),
(0,53,'5##############'),
(0,53,'5##############'),
(0,53,'5##############'),
(0,53,'5##############'),
(0,53,'1##############'),
(0,53,'4##############'),
(0,53,'4##############'),
(0,53,'4##############'),
(0,54,'5##############'),
(0,54,'1##############'),
(0,54,'4##############'),
(0,55,'30000#5#############'),
(0,55,'40000#5#############'),
(0,55,'25000#5#############'),
(0,55,'38000#5#############'),
(0,55,'55000#1#############'),
(0,55,'43000#4#############'),
(0,55,'25000#4#############'),
(0,55,'25000#4#############'),
(0,56,'30000#5#############'),
(0,56,'40000#5#############'),
(0,56,'25000#5#############'),
(0,56,'38000#5#############'),
(0,56,'55000#1#############'),
(0,56,'43000#4#############'),
(0,56,'25000#4#############'),
(0,60,'john#smith#731fondren,houstontx############'),
(0,60,'franklin#wong#638voss,houstontx############'),
(0,60,'joyce#english#5631rice,houstontx############'),
(0,60,'ramesh#narayan#975fireoak,humbletx############'),
(0,61,'james#borg#450stone,houstontx############'),
(0,61,'jennifer#wallace#291berry,bellairetx############'),
(0,61,'ahmad#jabbar#980dallas,houstontx############'),
(0,61,'alicia#zelaya#3321castle,springtx############'),
(0,62,'franklin#wong#638voss,houstontx############'),
(0,62,'ramesh#narayan#975fireoak,humbletx############'),
(0,62,'james#borg#450stone,houstontx############'),
(0,62,'jennifer#wallace#291berry,bellairetx############'),
(0,63,'john#smith#731fondren,houstontx############'),
(0,63,'franklin#wong#638voss,houstontx############'),
(0,63,'joyce#english#5631rice,houstontx############'),
(0,63,'ramesh#narayan#975fireoak,humbletx############'),
(0,63,'james#borg#450stone,houstontx############'),
(0,63,'jennifer#wallace#291berry,bellairetx############'),
(0,64,'franklin#wong#638voss,houstontx############'),
(0,64,'ramesh#narayan#975fireoak,humbletx############'),
(0,65,'joyce#english#5631rice,houstontx#1972-07-31###########'),
(0,65,'ahmad#jabbar#980dallas,houstontx#1969-03-29###########'),
(0,65,'alicia#zelaya#3321castle,springtx#1968-01-19###########'),
(0,66,'john#smith#731fondren,houstontx#1965-01-09###########'),
(0,66,'ahmad#jabbar#980dallas,houstontx#1969-03-29###########'),
(0,66,'alicia#zelaya#3321castle,springtx#1968-01-19###########'),
(0,67,'john#smith#731fondren,houstontx############'),
(0,67,'franklin#wong#638voss,houstontx############'),
(0,67,'joyce#english#5631rice,houstontx############'),
(0,67,'ramesh#narayan#975fireoak,humbletx############'),
(0,67,'james#borg#450stone,houstontx############'),
(0,67,'jennifer#wallace#291berry,bellairetx############'),
(0,67,'ahmad#jabbar#980dallas,houstontx############'),
(0,67,'alicia#zelaya#3321castle,springtx############'),
(0,68,'john#smith#731fondren,houstontx############'),
(0,68,'franklin#wong#638voss,houstontx############'),
(0,68,'joyce#english#5631rice,houstontx############'),
(0,68,'ramesh#narayan#975fireoak,humbletx############'),
(0,68,'james#borg#450stone,houstontx############'),
(0,68,'jennifer#wallace#291berry,bellairetx############'),
(0,68,'ahmad#jabbar#980dallas,houstontx############'),
(0,68,'alicia#zelaya#3321castle,springtx############'),
(0,69,'john#731fondren,houstontx#############'),
(0,69,'franklin#638voss,houstontx#############'),
(0,69,'joyce#5631rice,houstontx#############'),
(0,69,'ramesh#975fireoak,humbletx#############'),
(0,69,'james#450stone,houstontx#############'),
(0,69,'jennifer#291berry,bellairetx#############'),
(0,69,'ahmad#980dallas,houstontx#############'),
(0,69,'alicia#3321castle,springtx#############'),
(0,70,'john#smith#731fondren,houstontx############'),
(0,70,'franklin#wong#638voss,houstontx############'),
(0,70,'joyce#english#5631rice,houstontx############'),
(0,70,'ramesh#narayan#975fireoak,humbletx############'),
(0,70,'james#borg#450stone,houstontx############'),
(0,70,'jennifer#wallace#291berry,bellairetx############'),
(0,70,'ahmad#jabbar#980dallas,houstontx############'),
(0,70,'alicia#zelaya#3321castle,springtx############'),
(0,71,'john#smith#731fondren,houstontx############'),
(0,71,'franklin#wong#638voss,houstontx############'),
(0,71,'joyce#english#5631rice,houstontx############'),
(0,71,'james#borg#450stone,houstontx############'),
(0,71,'ahmad#jabbar#980dallas,houstontx############'),
(0,72,'ahmad#jabbar#980dallas,houstontx############'),
(0,73,'john#smith#731fondren,houstontx############'),
(0,73,'joyce#english#5631rice,houstontx############'),
(0,73,'james#borg#450stone,houstontx############'),
(0,73,'jennifer#wallace#291berry,bellairetx############'),
(0,74,'ramesh#narayan#975fireoak,humbletx############'),
(0,74,'alicia#zelaya#3321castle,springtx############'),
(0,75,'ramesh#narayan#975fireoak,humbletx############'),
(0,80,'john#smith#33000.000000000############'),
(0,80,'franklin#wong#44000.000000000############'),
(0,80,'joyce#english#27500.000000000############'),
(0,80,'ramesh#narayan#41800.000000000############'),
(0,81,'133000##############'),
(0,82,'25000#40000#############'),
(0,83,'6##############'),
(0,84,'3##############'),
(0,85,'3##############'),
(0,86,'4##############'),
(0,87,'8##############'),
(0,88,'5#25000#33250.0000#40000###########'),
(0,88,'1#55000#55000.0000#55000###########'),
(0,88,'4#25000#31000.0000#43000###########'),
(0,89,'1#55000#55000.0000#55000###########'),
(0,89,'4#25000#31000.0000#43000###########'),
(0,100,'5#3#############'),
(0,100,'1#1#############'),
(0,100,'4#1#############'),
(0,101,'5#3#############'),
(0,101,'4#1#############'),
(0,102,'1##############'),
(0,102,'4##############'),
(0,103,'1#1#############'),
(0,103,'4#1#############'),
(0,104,'john#smith#731fondren,houstontx############'),
(0,104,'franklin#wong#638voss,houstontx############'),
(0,105,'franklin#wong#638voss,houstontx############'),
(0,105,'ramesh#narayan#975fireoak,humbletx############'),
(0,105,'james#borg#450stone,houstontx############'),
(0,105,'jennifer#wallace#291berry,bellairetx############'),
(0,106,'123456789##############'),
(0,106,'333445555##############'),
(0,106,'666884444##############'),
(0,106,'888665555##############'),
(0,106,'987654321##############'),
(0,107,'333445555##############'),
(0,107,'888665555##############'),
(0,107,'987654321##############'),
(0,108,'123456789##############'),
(0,108,'666884444##############'),
(0,120,'john#smith#731fondren,houstontx#5#5#research#########'),
(0,120,'john#smith#731fondren,houstontx#5#1#headquarters#########'),
(0,120,'john#smith#731fondren,houstontx#5#4#administration#########'),
(0,120,'franklin#wong#638voss,houstontx#5#5#research#########'),
(0,120,'franklin#wong#638voss,houstontx#5#1#headquarters#########'),
(0,120,'franklin#wong#638voss,houstontx#5#4#administration#########'),
(0,120,'joyce#english#5631rice,houstontx#5#5#research#########'),
(0,120,'joyce#english#5631rice,houstontx#5#1#headquarters#########'),
(0,120,'joyce#english#5631rice,houstontx#5#4#administration#########'),
(0,120,'ramesh#narayan#975fireoak,humbletx#5#5#research#########'),
(0,120,'ramesh#narayan#975fireoak,humbletx#5#1#headquarters#########'),
(0,120,'ramesh#narayan#975fireoak,humbletx#5#4#administration#########'),
(0,120,'james#borg#450stone,houstontx#1#5#research#########'),
(0,120,'james#borg#450stone,houstontx#1#1#headquarters#########'),
(0,120,'james#borg#450stone,houstontx#1#4#administration#########'),
(0,120,'jennifer#wallace#291berry,bellairetx#4#5#research#########'),
(0,120,'jennifer#wallace#291berry,bellairetx#4#1#headquarters#########'),
(0,120,'jennifer#wallace#291berry,bellairetx#4#4#administration#########'),
(0,120,'ahmad#jabbar#980dallas,houstontx#4#5#research#########'),
(0,120,'ahmad#jabbar#980dallas,houstontx#4#1#headquarters#########'),
(0,120,'ahmad#jabbar#980dallas,houstontx#4#4#administration#########'),
(0,120,'alicia#zelaya#3321castle,springtx#4#5#research#########'),
(0,120,'alicia#zelaya#3321castle,springtx#4#1#headquarters#########'),
(0,120,'alicia#zelaya#3321castle,springtx#4#4#administration#########'),
(0,121,'john#smith#731fondren,houstontx#research#5##########'),
(0,121,'franklin#wong#638voss,houstontx#research#5##########'),
(0,121,'joyce#english#5631rice,houstontx#research#5##########'),
(0,121,'ramesh#narayan#975fireoak,humbletx#research#5##########'),
(0,121,'james#borg#450stone,houstontx#headquarters#1##########'),
(0,121,'jennifer#wallace#291berry,bellairetx#administration#4##########'),
(0,121,'ahmad#jabbar#980dallas,houstontx#administration#4##########'),
(0,121,'alicia#zelaya#3321castle,springtx#administration#4##########'),
(0,122,'john#smith#731fondren,houstontx#research#5##########'),
(0,122,'franklin#wong#638voss,houstontx#research#5##########'),
(0,122,'joyce#english#5631rice,houstontx#research#5##########'),
(0,122,'ramesh#narayan#975fireoak,humbletx#research#5##########'),
(0,122,'james#borg#450stone,houstontx#headquarters#1##########'),
(0,122,'jennifer#wallace#291berry,bellairetx#administration#4##########'),
(0,122,'ahmad#jabbar#980dallas,houstontx#administration#4##########'),
(0,122,'alicia#zelaya#3321castle,springtx#administration#4##########'),
(0,123,'john#smith#731fondren,houstontx#research#5##########'),
(0,123,'franklin#wong#638voss,houstontx#research#5##########'),
(0,123,'joyce#english#5631rice,houstontx#research#5##########'),
(0,123,'ramesh#narayan#975fireoak,humbletx#research#5##########'),
(0,123,'james#borg#450stone,houstontx#headquarters#1##########'),
(0,123,'jennifer#wallace#291berry,bellairetx#administration#4##########'),
(0,123,'ahmad#jabbar#980dallas,houstontx#administration#4##########'),
(0,123,'alicia#zelaya#3321castle,springtx#administration#4##########'),
(0,124,'john#smith#731fondren,houstontx#333445555#franklin#wong#########'),
(0,124,'franklin#wong#638voss,houstontx#888665555#james#borg#########'),
(0,124,'joyce#english#5631rice,houstontx#333445555#franklin#wong#########'),
(0,124,'ramesh#narayan#975fireoak,humbletx#333445555#franklin#wong#########'),
(0,124,'james#borg#450stone,houstontx############'),
(0,124,'jennifer#wallace#291berry,bellairetx#888665555#james#borg#########'),
(0,124,'ahmad#jabbar#980dallas,houstontx#987654321#jennifer#wallace#########'),
(0,124,'alicia#zelaya#3321castle,springtx#987654321#jennifer#wallace#########'),
(0,125,'alice#1988-12-30#john#smith###########'),
(0,125,'elizabeth#1967-05-05#john#smith###########'),
(0,125,'michael#1988-01-04#john#smith###########'),
(0,125,'alice#1986-04-04#franklin#wong###########'),
(0,125,'joy#1958-05-03#franklin#wong###########'),
(0,125,'theodore#1983-10-25#franklin#wong###########'),
(0,125,'##joyce#english###########'),
(0,125,'##ramesh#narayan###########'),
(0,125,'##james#borg###########'),
(0,125,'abner#1942-02-28#jennifer#wallace###########'),
(0,125,'##ahmad#jabbar###########'),
(0,125,'##alicia#zelaya###########'),
(0,126,'james#borg#headquarters#1###########'),
(0,126,'jennifer#wallace#administration#4###########'),
(0,126,'franklin#wong#research#5###########'),
(0,127,'john#smith#5############'),
(0,127,'franklin#wong#5#research###########'),
(0,127,'joyce#english#5############'),
(0,127,'ramesh#narayan#5############'),
(0,127,'james#borg#1#headquarters###########'),
(0,127,'jennifer#wallace#4#administration###########'),
(0,127,'ahmad#jabbar#4############'),
(0,127,'alicia#zelaya#4############'),
(0,128,'john#smith#731fondren,houstontx#reorganization#houston##########'),
(0,128,'john#smith#731fondren,houstontx#productz#houston##########'),
(0,128,'franklin#wong#638voss,houstontx#reorganization#houston##########'),
(0,128,'franklin#wong#638voss,houstontx#productz#houston##########'),
(0,128,'joyce#english#5631rice,houstontx#reorganization#houston##########'),
(0,128,'joyce#english#5631rice,houstontx#productz#houston##########'),
(0,128,'james#borg#450stone,houstontx#reorganization#houston##########'),
(0,128,'james#borg#450stone,houstontx#productz#houston##########'),
(0,128,'jennifer#wallace#291berry,bellairetx#productx#bellaire##########'),
(0,128,'ahmad#jabbar#980dallas,houstontx#reorganization#houston##########'),
(0,128,'ahmad#jabbar#980dallas,houstontx#productz#houston##########'),
(0,129,'james#borg#1937-11-10#franklin#wong#1955-12-08#########'),
(0,129,'james#borg#1937-11-10#jennifer#wallace#1941-06-20#########'),
(0,129,'jennifer#wallace#1941-06-20#franklin#wong#1955-12-08#########'),
(1,0,'1965-01-09#731fondren,houstontx#############'),
(1,1,'john#smith#731fondren,houstontx############'),
(1,1,'franklin#wong#638voss,houstontx############'),
(1,1,'joyce#english#5631rice,houstontx############'),
(1,1,'ramesh#narayan#975fireoak,humbletx############'),
(1,4,'1##############'),
(1,4,'2##############'),
(1,5,'john#smith#############'),
(1,5,'franklin#wong#############'),
(1,6,'joyce#english#############'),
(1,6,'ramesh#narayan#############'),
(1,6,'james#borg#############'),
(1,7,'franklin#wong#############'),
(1,8,'john#smith#franklin#wong###########'),
(1,8,'franklin#wong#james#borg###########'),
(1,8,'joyce#english#franklin#wong###########'),
(1,8,'ramesh#narayan#franklin#wong###########'),
(1,8,'james#borg#############'),
(1,9,'123456789##############'),
(1,9,'333445555##############'),
(1,9,'453453453##############'),
(1,9,'666884444##############'),
(1,9,'888665555##############'),
(1,10,'123456789#research#############'),
(1,10,'123456789#headquarters#############'),
(1,10,'333445555#research#############'),
(1,10,'333445555#headquarters#############'),
(1,10,'453453453#research#############'),
(1,10,'453453453#headquarters#############'),
(1,10,'666884444#research#############'),
(1,10,'666884444#headquarters#############'),
(1,10,'888665555#research#############'),
(1,10,'888665555#headquarters#############'),
(1,11,'30000##############'),
(1,11,'40000##############'),
(1,11,'25000##############'),
(1,11,'38000##############'),
(1,11,'55000##############'),
(1,12,'john#smith#############'),
(1,12,'franklin#wong#############'),
(1,12,'joyce#english#############'),
(1,12,'james#borg#############'),
(1,13,'franklin#wong#40000.00############'),
(1,13,'ramesh#narayan#38000.00############'),
(1,13,'james#borg#55000.00############'),
(1,13,'john#smith#33000.00############'),
(1,13,'joyce#english#27500.00############'),
(1,14,'john#smith#123456789#1965-01-09#731fondren,houstontx#m#30000#333445555#5######'),
(1,14,'franklin#wong#333445555#1955-12-08#638voss,houstontx#m#40000#888665555#5######'),
(1,14,'ramesh#narayan#666884444#1962-09-15#975fireoak,humbletx#m#38000#333445555#5######'),
(1,15,'research#smith#john#productx###########'),
(1,15,'research#smith#john#producty###########'),
(1,15,'research#wong#franklin#producty###########'),
(1,15,'research#wong#franklin#productz###########'),
(1,15,'research#wong#franklin#reorganization###########'),
(1,15,'research#english#joyce#productx###########'),
(1,15,'research#english#joyce#producty###########'),
(1,15,'research#narayan#ramesh#productz###########'),
(1,15,'headquarters#borg#james#reorganization###########'),
(1,17,'123456789##############'),
(1,17,'333445555##############'),
(1,17,'453453453##############'),
(1,17,'666884444##############'),
(1,18,'james#borg#############'),
(1,19,'188000#55000#25000#37600.0000###########'),
(1,20,'133000#40000#25000#33250.0000###########'),
(1,21,'5##############'),
(1,22,'4##############'),
(1,23,'5##############'),
(1,24,'5#4#33250.0000############'),
(1,24,'1#1#55000.0000############'),
(1,25,'1#productx#2############'),
(1,25,'2#producty#3############'),
(1,25,'3#productz#2############'),
(1,25,'20#reorganization#2############'),
(1,26,'2#producty#3############'),
(1,27,'1#productx#2############'),
(1,27,'2#producty#3############'),
(1,27,'3#productz#2############'),
(1,27,'20#reorganization#1############'),
(1,28,'1#1#############'),
(1,29,'john#smith#123456789#1965-01-09#731fondren,houstontx#m#30000#333445555#5######'),
(1,29,'franklin#wong#333445555#1955-12-08#638voss,houstontx#m#40000#888665555#5######'),
(1,29,'joyce#english#453453453#1972-07-31#5631rice,houstontx#f#25000#333445555#5######'),
(1,29,'ramesh#narayan#666884444#1962-09-15#975fireoak,humbletx#m#38000#333445555#5######'),
(1,30,'john#smith#123456789#1965-01-09#731fondren,houstontx#m#30000#333445555#5#research#5#333445555#1988-05-22##'),
(1,30,'franklin#wong#333445555#1955-12-08#638voss,houstontx#m#40000#888665555#5#research#5#333445555#1988-05-22##'),
(1,30,'joyce#english#453453453#1972-07-31#5631rice,houstontx#f#25000#333445555#5#research#5#333445555#1988-05-22##'),
(1,30,'ramesh#narayan#666884444#1962-09-15#975fireoak,humbletx#m#38000#333445555#5#research#5#333445555#1988-05-22##'),
(1,30,'james#borg#888665555#1937-11-10#450stone,houstontx#m#55000##1#headquarters#1#888665555#1981-06-19##'),
(1,31,'franklin#wong#1955-12-08############'),
(1,32,'john#smith#############'),
(1,32,'joyce#english#############'),
(1,34,'john#smith#############'),
(1,34,'joyce#english#############'),
(1,34,'ramesh#narayan#############'),
(1,35,'james#borg#############'),
(1,36,'john#smith#############'),
(1,36,'joyce#english#############'),
(1,36,'ramesh#narayan#############'),
(1,37,'franklin#wong#############'),
(1,37,'ramesh#narayan#############'),
(1,37,'james#borg#############'),
(1,40,'helloworld!##############'),
(1,41,'helloworld!##############'),
(1,42,'10##############'),
(1,43,'10#21#4############'),
(1,44,'john#smith#123456789#1965-01-09#731fondren,houstontx#m#30000#333445555#5######'),
(1,44,'franklin#wong#333445555#1955-12-08#638voss,houstontx#m#40000#888665555#5######'),
(1,44,'joyce#english#453453453#1972-07-31#5631rice,houstontx#f#25000#333445555#5######'),
(1,44,'ramesh#narayan#666884444#1962-09-15#975fireoak,humbletx#m#38000#333445555#5######'),
(1,44,'james#borg#888665555#1937-11-10#450stone,houstontx#m#55000##1######'),
(1,50,'john#smith#731fondren,houstontx############'),
(1,50,'franklin#wong#638voss,houstontx############'),
(1,50,'joyce#english#5631rice,houstontx############'),
(1,50,'ramesh#narayan#975fireoak,humbletx############'),
(1,50,'james#borg#450stone,houstontx############'),
(1,51,'smith#john#731fondren,houstontx############'),
(1,51,'wong#franklin#638voss,houstontx############'),
(1,51,'english#joyce#5631rice,houstontx############'),
(1,51,'narayan#ramesh#975fireoak,humbletx############'),
(1,51,'borg#james#450stone,houstontx############'),
(1,52,'johnsmith#731fondren,houstontx#############'),
(1,52,'franklinwong#638voss,houstontx#############'),
(1,52,'joyceenglish#5631rice,houstontx#############'),
(1,52,'rameshnarayan#975fireoak,humbletx#############'),
(1,52,'jamesborg#450stone,houstontx#############'),
(1,53,'5##############'),
(1,53,'5##############'),
(1,53,'5##############'),
(1,53,'5##############'),
(1,53,'1##############'),
(1,54,'5##############'),
(1,54,'1##############'),
(1,55,'30000#5#############'),
(1,55,'40000#5#############'),
(1,55,'25000#5#############'),
(1,55,'38000#5#############'),
(1,55,'55000#1#############'),
(1,56,'30000#5#############'),
(1,56,'40000#5#############'),
(1,56,'25000#5#############'),
(1,56,'38000#5#############'),
(1,56,'55000#1#############'),
(1,60,'john#smith#731fondren,houstontx############'),
(1,60,'franklin#wong#638voss,houstontx############'),
(1,60,'joyce#english#5631rice,houstontx############'),
(1,60,'ramesh#narayan#975fireoak,humbletx############'),
(1,61,'james#borg#450stone,houstontx############'),
(1,62,'franklin#wong#638voss,houstontx############'),
(1,62,'ramesh#narayan#975fireoak,humbletx############'),
(1,62,'james#borg#450stone,houstontx############'),
(1,63,'john#smith#731fondren,houstontx############'),
(1,63,'franklin#wong#638voss,houstontx############'),
(1,63,'joyce#english#5631rice,houstontx############'),
(1,63,'ramesh#narayan#975fireoak,humbletx############'),
(1,63,'james#borg#450stone,houstontx############'),
(1,64,'franklin#wong#638voss,houstontx############'),
(1,64,'ramesh#narayan#975fireoak,humbletx############'),
(1,65,'joyce#english#5631rice,houstontx#1972-07-31###########'),
(1,66,'john#smith#731fondren,houstontx#1965-01-09###########'),
(1,67,'john#smith#731fondren,houstontx############'),
(1,67,'franklin#wong#638voss,houstontx############'),
(1,67,'joyce#english#5631rice,houstontx############'),
(1,67,'ramesh#narayan#975fireoak,humbletx############'),
(1,67,'james#borg#450stone,houstontx############'),
(1,68,'john#smith#731fondren,houstontx############'),
(1,68,'franklin#wong#638voss,houstontx############'),
(1,68,'joyce#english#5631rice,houstontx############'),
(1,68,'ramesh#narayan#975fireoak,humbletx############'),
(1,68,'james#borg#450stone,houstontx############'),
(1,69,'john#731fondren,houstontx#############'),
(1,69,'franklin#638voss,houstontx#############'),
(1,69,'joyce#5631rice,houstontx#############'),
(1,69,'ramesh#975fireoak,humbletx#############'),
(1,69,'james#450stone,houstontx#############'),
(1,70,'john#smith#731fondren,houstontx############'),
(1,70,'franklin#wong#638voss,houstontx############'),
(1,70,'joyce#english#5631rice,houstontx############'),
(1,70,'ramesh#narayan#975fireoak,humbletx############'),
(1,70,'james#borg#450stone,houstontx############'),
(1,71,'john#smith#731fondren,houstontx############'),
(1,71,'franklin#wong#638voss,houstontx############'),
(1,71,'joyce#english#5631rice,houstontx############'),
(1,71,'james#borg#450stone,houstontx############'),
(1,73,'john#smith#731fondren,houstontx############'),
(1,73,'joyce#english#5631rice,houstontx############'),
(1,73,'james#borg#450stone,houstontx############'),
(1,74,'ramesh#narayan#975fireoak,humbletx############'),
(1,75,'ramesh#narayan#975fireoak,humbletx############'),
(1,80,'john#smith#33000.000000000############'),
(1,80,'franklin#wong#44000.000000000############'),
(1,80,'joyce#english#27500.000000000############'),
(1,80,'ramesh#narayan#41800.000000000############'),
(1,81,'133000##############'),
(1,82,'25000#40000#############'),
(1,83,'5##############'),
(1,84,'2##############'),
(1,85,'3##############'),
(1,86,'1##############'),
(1,87,'5##############'),
(1,88,'5#25000#33250.0000#40000###########'),
(1,88,'1#55000#55000.0000#55000###########'),
(1,89,'1#55000#55000.0000#55000###########'),
(1,100,'5#3#############'),
(1,100,'1#1#############'),
(1,101,'5#3#############'),
(1,102,'1##############'),
(1,103,'1#1#############'),
(1,104,'john#smith#731fondren,houstontx############'),
(1,104,'franklin#wong#638voss,houstontx############'),
(1,105,'franklin#wong#638voss,houstontx############'),
(1,105,'ramesh#narayan#975fireoak,humbletx############'),
(1,105,'james#borg#450stone,houstontx############'),
(1,106,'123456789##############'),
(1,106,'333445555##############'),
(1,106,'666884444##############'),
(1,106,'888665555##############'),
(1,107,'333445555##############'),
(1,107,'888665555##############'),
(1,108,'123456789##############'),
(1,108,'666884444##############'),
(1,120,'john#smith#731fondren,houstontx#5#5#research#########'),
(1,120,'john#smith#731fondren,houstontx#5#1#headquarters#########'),
(1,120,'franklin#wong#638voss,houstontx#5#5#research#########'),
(1,120,'franklin#wong#638voss,houstontx#5#1#headquarters#########'),
(1,120,'joyce#english#5631rice,houstontx#5#5#research#########'),
(1,120,'joyce#english#5631rice,houstontx#5#1#headquarters#########'),
(1,120,'ramesh#narayan#975fireoak,humbletx#5#5#research#########'),
(1,120,'ramesh#narayan#975fireoak,humbletx#5#1#headquarters#########'),
(1,120,'james#borg#450stone,houstontx#1#5#research#########'),
(1,120,'james#borg#450stone,houstontx#1#1#headquarters#########'),
(1,121,'john#smith#731fondren,houstontx#research#5##########'),
(1,121,'franklin#wong#638voss,houstontx#research#5##########'),
(1,121,'joyce#english#5631rice,houstontx#research#5##########'),
(1,121,'ramesh#narayan#975fireoak,humbletx#research#5##########'),
(1,121,'james#borg#450stone,houstontx#headquarters#1##########'),
(1,122,'john#smith#731fondren,houstontx#research#5##########'),
(1,122,'franklin#wong#638voss,houstontx#research#5##########'),
(1,122,'joyce#english#5631rice,houstontx#research#5##########'),
(1,122,'ramesh#narayan#975fireoak,humbletx#research#5##########'),
(1,122,'james#borg#450stone,houstontx#headquarters#1##########'),
(1,123,'john#smith#731fondren,houstontx#research#5##########'),
(1,123,'franklin#wong#638voss,houstontx#research#5##########'),
(1,123,'joyce#english#5631rice,houstontx#research#5##########'),
(1,123,'ramesh#narayan#975fireoak,humbletx#research#5##########'),
(1,123,'james#borg#450stone,houstontx#headquarters#1##########'),
(1,124,'john#smith#731fondren,houstontx#333445555#franklin#wong#########'),
(1,124,'franklin#wong#638voss,houstontx#888665555#james#borg#########'),
(1,124,'joyce#english#5631rice,houstontx#333445555#franklin#wong#########'),
(1,124,'ramesh#narayan#975fireoak,humbletx#333445555#franklin#wong#########'),
(1,124,'james#borg#450stone,houstontx############'),
(1,125,'alice#1988-12-30#john#smith###########'),
(1,125,'elizabeth#1967-05-05#john#smith###########'),
(1,125,'michael#1988-01-04#john#smith###########'),
(1,125,'alice#1986-04-04#franklin#wong###########'),
(1,125,'joy#1958-05-03#franklin#wong###########'),
(1,125,'theodore#1983-10-25#franklin#wong###########'),
(1,125,'##joyce#english###########'),
(1,125,'##ramesh#narayan###########'),
(1,125,'##james#borg###########'),
(1,126,'james#borg#headquarters#1###########'),
(1,126,'franklin#wong#research#5###########'),
(1,127,'john#smith#5############'),
(1,127,'franklin#wong#5#research###########'),
(1,127,'joyce#english#5############'),
(1,127,'ramesh#narayan#5############'),
(1,127,'james#borg#1#headquarters###########'),
(1,128,'john#smith#731fondren,houstontx#reorganization#houston##########'),
(1,128,'john#smith#731fondren,houstontx#productz#houston##########'),
(1,128,'franklin#wong#638voss,houstontx#reorganization#houston##########'),
(1,128,'franklin#wong#638voss,houstontx#productz#houston##########'),
(1,128,'joyce#english#5631rice,houstontx#reorganization#houston##########'),
(1,128,'joyce#english#5631rice,houstontx#productz#houston##########'),
(1,128,'james#borg#450stone,houstontx#reorganization#houston##########'),
(1,128,'james#borg#450stone,houstontx#productz#houston##########'),
(1,129,'james#borg#1937-11-10#franklin#wong#1955-12-08#########'),
(2,2,'10#4#wallace#291berry,bellairetx#1941-06-20##########'),
(2,2,'30#4#wallace#291berry,bellairetx#1941-06-20##########'),
(2,3,'james#borg#############'),
(2,3,'jennifer#wallace#############'),
(2,3,'ahmad#jabbar#############'),
(2,3,'alicia#zelaya#############'),
(2,6,'james#borg#############'),
(2,6,'ahmad#jabbar#############'),
(2,6,'alicia#zelaya#############'),
(2,7,'jennifer#wallace#############'),
(2,8,'james#borg#############'),
(2,8,'jennifer#wallace#james#borg###########'),
(2,8,'ahmad#jabbar#jennifer#wallace###########'),
(2,8,'alicia#zelaya#jennifer#wallace###########'),
(2,9,'888665555##############'),
(2,9,'987654321##############'),
(2,9,'987987987##############'),
(2,9,'999887777##############'),
(2,10,'888665555#headquarters#############'),
(2,10,'888665555#administration#############'),
(2,10,'987654321#headquarters#############'),
(2,10,'987654321#administration#############'),
(2,10,'987987987#headquarters#############'),
(2,10,'987987987#administration#############'),
(2,10,'999887777#headquarters#############'),
(2,10,'999887777#administration#############'),
(2,11,'55000##############'),
(2,11,'43000##############'),
(2,11,'25000##############'),
(2,12,'james#borg#############'),
(2,12,'ahmad#jabbar#############'),
(2,13,'james#borg#55000.00############'),
(2,13,'jennifer#wallace#43000.00############'),
(2,13,'ahmad#jabbar#25000.00############'),
(2,13,'alicia#zelaya#25000.00############'),
(2,15,'headquarters#borg#james#reorganization###########'),
(2,15,'administration#wallace#jennifer#reorganization###########'),
(2,15,'administration#wallace#jennifer#newbenefits###########'),
(2,15,'administration#jabbar#ahmad#computerization###########'),
(2,15,'administration#jabbar#ahmad#newbenefits###########'),
(2,15,'administration#zelaya#alicia#computerization###########'),
(2,15,'administration#zelaya#alicia#newbenefits###########'),
(2,18,'james#borg#############'),
(2,19,'148000#55000#25000#37000.0000###########'),
(2,20,'##############'),
(2,21,'4##############'),
(2,22,'0##############'),
(2,23,'3##############'),
(2,24,'1#1#55000.0000############'),
(2,24,'4#3#31000.0000############'),
(2,25,'10#computerization#2############'),
(2,25,'30#newbenefits#3############'),
(2,25,'20#reorganization#2############'),
(2,26,'30#newbenefits#3############'),
(2,27,'10#computerization#0############'),
(2,27,'30#newbenefits#0############'),
(2,27,'20#reorganization#0############'),
(2,28,'1#1#############'),
(2,28,'4#1#############'),
(2,30,'james#borg#888665555#1937-11-10#450stone,houstontx#m#55000##1#headquarters#1#888665555#1981-06-19##'),
(2,30,'jennifer#wallace#987654321#1941-06-20#291berry,bellairetx#f#43000#888665555#4#administration#4#987654321#1995-01-01##'),
(2,30,'ahmad#jabbar#987987987#1969-03-29#980dallas,houstontx#m#25000#987654321#4#administration#4#987654321#1995-01-01##'),
(2,30,'alicia#zelaya#999887777#1968-01-19#3321castle,springtx#f#25000#987654321#4#administration#4#987654321#1995-01-01##'),
(2,35,'james#borg#############'),
(2,36,'ahmad#jabbar#############'),
(2,36,'alicia#zelaya#############'),
(2,37,'james#borg#############'),
(2,37,'jennifer#wallace#############'),
(2,40,'helloworld!##############'),
(2,41,'helloworld!##############'),
(2,42,'10##############'),
(2,43,'10#21#4############'),
(2,44,'james#borg#888665555#1937-11-10#450stone,houstontx#m#55000##1######'),
(2,44,'jennifer#wallace#987654321#1941-06-20#291berry,bellairetx#f#43000#888665555#4######'),
(2,44,'ahmad#jabbar#987987987#1969-03-29#980dallas,houstontx#m#25000#987654321#4######'),
(2,44,'alicia#zelaya#999887777#1968-01-19#3321castle,springtx#f#25000#987654321#4######'),
(2,50,'james#borg#450stone,houstontx############'),
(2,50,'jennifer#wallace#291berry,bellairetx############'),
(2,50,'ahmad#jabbar#980dallas,houstontx############'),
(2,50,'alicia#zelaya#3321castle,springtx############'),
(2,51,'borg#james#450stone,houstontx############'),
(2,51,'wallace#jennifer#291berry,bellairetx############'),
(2,51,'jabbar#ahmad#980dallas,houstontx############'),
(2,51,'zelaya#alicia#3321castle,springtx############'),
(2,52,'jamesborg#450stone,houstontx#############'),
(2,52,'jenniferwallace#291berry,bellairetx#############'),
(2,52,'ahmadjabbar#980dallas,houstontx#############'),
(2,52,'aliciazelaya#3321castle,springtx#############'),
(2,53,'1##############'),
(2,53,'4##############'),
(2,53,'4##############'),
(2,53,'4##############'),
(2,54,'1##############'),
(2,54,'4##############'),
(2,55,'55000#1#############'),
(2,55,'43000#4#############'),
(2,55,'25000#4#############'),
(2,55,'25000#4#############'),
(2,56,'55000#1#############'),
(2,56,'43000#4#############'),
(2,56,'25000#4#############'),
(2,61,'james#borg#450stone,houstontx############'),
(2,61,'jennifer#wallace#291berry,bellairetx############'),
(2,61,'ahmad#jabbar#980dallas,houstontx############'),
(2,61,'alicia#zelaya#3321castle,springtx############'),
(2,62,'james#borg#450stone,houstontx############'),
(2,62,'jennifer#wallace#291berry,bellairetx############'),
(2,63,'james#borg#450stone,houstontx############'),
(2,63,'jennifer#wallace#291berry,bellairetx############'),
(2,65,'ahmad#jabbar#980dallas,houstontx#1969-03-29###########'),
(2,65,'alicia#zelaya#3321castle,springtx#1968-01-19###########'),
(2,66,'ahmad#jabbar#980dallas,houstontx#1969-03-29###########'),
(2,66,'alicia#zelaya#3321castle,springtx#1968-01-19###########'),
(2,67,'james#borg#450stone,houstontx############'),
(2,67,'jennifer#wallace#291berry,bellairetx############'),
(2,67,'ahmad#jabbar#980dallas,houstontx############'),
(2,67,'alicia#zelaya#3321castle,springtx############'),
(2,68,'james#borg#450stone,houstontx############'),
(2,68,'jennifer#wallace#291berry,bellairetx############'),
(2,68,'ahmad#jabbar#980dallas,houstontx############'),
(2,68,'alicia#zelaya#3321castle,springtx############'),
(2,69,'james#450stone,houstontx#############'),
(2,69,'jennifer#291berry,bellairetx#############'),
(2,69,'ahmad#980dallas,houstontx#############'),
(2,69,'alicia#3321castle,springtx#############'),
(2,70,'james#borg#450stone,houstontx############'),
(2,70,'jennifer#wallace#291berry,bellairetx############'),
(2,70,'ahmad#jabbar#980dallas,houstontx############'),
(2,70,'alicia#zelaya#3321castle,springtx############'),
(2,71,'james#borg#450stone,houstontx############'),
(2,71,'ahmad#jabbar#980dallas,houstontx############'),
(2,72,'ahmad#jabbar#980dallas,houstontx############'),
(2,73,'james#borg#450stone,houstontx############'),
(2,73,'jennifer#wallace#291berry,bellairetx############'),
(2,74,'alicia#zelaya#3321castle,springtx############'),
(2,81,'##############'),
(2,82,'##############'),
(2,83,'3##############'),
(2,84,'2##############'),
(2,85,'0##############'),
(2,86,'3##############'),
(2,87,'4##############'),
(2,88,'1#55000#55000.0000#55000###########'),
(2,88,'4#25000#31000.0000#43000###########'),
(2,89,'1#55000#55000.0000#55000###########'),
(2,89,'4#25000#31000.0000#43000###########'),
(2,100,'1#1#############'),
(2,100,'4#1#############'),
(2,101,'4#1#############'),
(2,102,'1##############'),
(2,102,'4##############'),
(2,103,'1#1#############'),
(2,103,'4#1#############'),
(2,105,'james#borg#450stone,houstontx############'),
(2,105,'jennifer#wallace#291berry,bellairetx############'),
(2,106,'888665555##############'),
(2,106,'987654321##############'),
(2,107,'888665555##############'),
(2,107,'987654321##############'),
(2,120,'james#borg#450stone,houstontx#1#1#headquarters#########'),
(2,120,'james#borg#450stone,houstontx#1#4#administration#########'),
(2,120,'jennifer#wallace#291berry,bellairetx#4#1#headquarters#########'),
(2,120,'jennifer#wallace#291berry,bellairetx#4#4#administration#########'),
(2,120,'ahmad#jabbar#980dallas,houstontx#4#1#headquarters#########'),
(2,120,'ahmad#jabbar#980dallas,houstontx#4#4#administration#########'),
(2,120,'alicia#zelaya#3321castle,springtx#4#1#headquarters#########'),
(2,120,'alicia#zelaya#3321castle,springtx#4#4#administration#########'),
(2,121,'james#borg#450stone,houstontx#headquarters#1##########'),
(2,121,'jennifer#wallace#291berry,bellairetx#administration#4##########'),
(2,121,'ahmad#jabbar#980dallas,houstontx#administration#4##########'),
(2,121,'alicia#zelaya#3321castle,springtx#administration#4##########'),
(2,122,'james#borg#450stone,houstontx#headquarters#1##########'),
(2,122,'jennifer#wallace#291berry,bellairetx#administration#4##########'),
(2,122,'ahmad#jabbar#980dallas,houstontx#administration#4##########'),
(2,122,'alicia#zelaya#3321castle,springtx#administration#4##########'),
(2,123,'james#borg#450stone,houstontx#headquarters#1##########'),
(2,123,'jennifer#wallace#291berry,bellairetx#administration#4##########'),
(2,123,'ahmad#jabbar#980dallas,houstontx#administration#4##########'),
(2,123,'alicia#zelaya#3321castle,springtx#administration#4##########'),
(2,124,'james#borg#450stone,houstontx############'),
(2,124,'jennifer#wallace#291berry,bellairetx#888665555#james#borg#########'),
(2,124,'ahmad#jabbar#980dallas,houstontx#987654321#jennifer#wallace#########'),
(2,124,'alicia#zelaya#3321castle,springtx#987654321#jennifer#wallace#########'),
(2,125,'##james#borg###########'),
(2,125,'abner#1942-02-28#jennifer#wallace###########'),
(2,125,'##ahmad#jabbar###########'),
(2,125,'##alicia#zelaya###########'),
(2,126,'james#borg#headquarters#1###########'),
(2,126,'jennifer#wallace#administration#4###########'),
(2,127,'james#borg#1#headquarters###########'),
(2,127,'jennifer#wallace#4#administration###########'),
(2,127,'ahmad#jabbar#4############'),
(2,127,'alicia#zelaya#4############'),
(2,128,'james#borg#450stone,houstontx#reorganization#houston##########'),
(2,128,'ahmad#jabbar#980dallas,houstontx#reorganization#houston##########'),
(2,129,'james#borg#1937-11-10#jennifer#wallace#1941-06-20#########'),
(3,0,'1965-01-09#731fondren,houstontx#############'),
(3,1,'john#smith#731fondren,houstontx############'),
(3,1,'franklin#wong#638voss,houstontx############'),
(3,1,'joyce#english#5631rice,houstontx############'),
(3,1,'ramesh#narayan#975fireoak,humbletx############'),
(3,2,'10#4#wallace#291berry,bellairetx#1941-06-20##########'),
(3,2,'30#4#wallace#291berry,bellairetx#1941-06-20##########'),
(3,4,'1##############'),
(3,4,'2##############'),
(3,4,'55##############'),
(3,5,'john#smith#############'),
(3,5,'franklin#wong#############'),
(3,5,'heike#weiss#############'),
(3,6,'camila#jackson#############'),
(3,6,'hector#cuevas#############'),
(3,6,'joyce#english#############'),
(3,6,'hiroto#watanabe#############'),
(3,6,'ramesh#narayan#############'),
(3,6,'alicia#smith#############'),
(3,6,'james#borg#############'),
(3,6,'ahmad#jabbar#############'),
(3,6,'alicia#zelaya#############'),
(3,7,'jennifer#wallace#############'),
(3,7,'franklin#wong#############'),
(3,8,'john#smith#franklin#wong###########'),
(3,8,'camila#jackson#hector#cuevas###########'),
(3,8,'hector#cuevas#james#borg###########'),
(3,8,'franklin#wong#james#borg###########'),
(3,8,'heike#weiss#hector#cuevas###########'),
(3,8,'joyce#english#franklin#wong###########'),
(3,8,'hiroto#watanabe#hector#cuevas###########'),
(3,8,'ramesh#narayan#franklin#wong###########'),
(3,8,'alicia#smith#hector#cuevas###########'),
(3,8,'james#borg#############'),
(3,8,'jennifer#wallace#james#borg###########'),
(3,8,'ahmad#jabbar#jennifer#wallace###########'),
(3,8,'alicia#zelaya#jennifer#wallace###########'),
(3,9,'123456789##############'),
(3,9,'163479608##############'),
(3,9,'235711131##############'),
(3,9,'333445555##############'),
(3,9,'378990405##############'),
(3,9,'453453453##############'),
(3,9,'510176317##############'),
(3,9,'666884444##############'),
(3,9,'701294005##############'),
(3,9,'888665555##############'),
(3,9,'987654321##############'),
(3,9,'987987987##############'),
(3,9,'999887777##############'),
(3,10,'123456789#reverseengineering#############'),
(3,10,'123456789#research#############'),
(3,10,'123456789#headquarters#############'),
(3,10,'123456789#administration#############'),
(3,10,'163479608#reverseengineering#############'),
(3,10,'163479608#research#############'),
(3,10,'163479608#headquarters#############'),
(3,10,'163479608#administration#############'),
(3,10,'235711131#reverseengineering#############'),
(3,10,'235711131#research#############'),
(3,10,'235711131#headquarters#############'),
(3,10,'235711131#administration#############'),
(3,10,'333445555#reverseengineering#############'),
(3,10,'333445555#research#############'),
(3,10,'333445555#headquarters#############'),
(3,10,'333445555#administration#############'),
(3,10,'378990405#reverseengineering#############'),
(3,10,'378990405#research#############'),
(3,10,'378990405#headquarters#############'),
(3,10,'378990405#administration#############'),
(3,10,'453453453#reverseengineering#############'),
(3,10,'453453453#research#############'),
(3,10,'453453453#headquarters#############'),
(3,10,'453453453#administration#############'),
(3,10,'510176317#reverseengineering#############'),
(3,10,'510176317#research#############'),
(3,10,'510176317#headquarters#############'),
(3,10,'510176317#administration#############'),
(3,10,'666884444#reverseengineering#############'),
(3,10,'666884444#research#############'),
(3,10,'666884444#headquarters#############'),
(3,10,'666884444#administration#############'),
(3,10,'701294005#reverseengineering#############'),
(3,10,'701294005#research#############'),
(3,10,'701294005#headquarters#############'),
(3,10,'701294005#administration#############'),
(3,10,'888665555#reverseengineering#############'),
(3,10,'888665555#research#############'),
(3,10,'888665555#headquarters#############'),
(3,10,'888665555#administration#############'),
(3,10,'987654321#reverseengineering#############'),
(3,10,'987654321#research#############'),
(3,10,'987654321#headquarters#############'),
(3,10,'987654321#administration#############'),
(3,10,'987987987#reverseengineering#############'),
(3,10,'987987987#research#############'),
(3,10,'987987987#headquarters#############'),
(3,10,'987987987#administration#############'),
(3,10,'999887777#reverseengineering#############'),
(3,10,'999887777#research#############'),
(3,10,'999887777#headquarters#############'),
(3,10,'999887777#administration#############'),
(3,11,'30000##############'),
(3,11,'37000##############'),
(3,11,'31000##############'),
(3,11,'40000##############'),
(3,11,'41000##############'),
(3,11,'25000##############'),
(3,11,'38000##############'),
(3,11,'51000##############'),
(3,11,'55000##############'),
(3,11,'43000##############'),
(3,12,'john#smith#############'),
(3,12,'franklin#wong#############'),
(3,12,'joyce#english#############'),
(3,12,'hiroto#watanabe#############'),
(3,12,'james#borg#############'),
(3,12,'ahmad#jabbar#############'),
(3,13,'camila#jackson#37000.00############'),
(3,13,'hector#cuevas#31000.00############'),
(3,13,'franklin#wong#40000.00############'),
(3,13,'heike#weiss#41000.00############'),
(3,13,'hiroto#watanabe#38000.00############'),
(3,13,'ramesh#narayan#38000.00############'),
(3,13,'alicia#smith#51000.00############'),
(3,13,'james#borg#55000.00############'),
(3,13,'jennifer#wallace#43000.00############'),
(3,13,'ahmad#jabbar#25000.00############'),
(3,13,'alicia#zelaya#25000.00############'),
(3,13,'john#smith#33000.00############'),
(3,13,'joyce#english#27500.00############'),
(3,14,'john#smith#123456789#1965-01-09#731fondren,houstontx#m#30000#333445555#5######'),
(3,14,'franklin#wong#333445555#1955-12-08#638voss,houstontx#m#40000#888665555#5######'),
(3,14,'ramesh#narayan#666884444#1962-09-15#975fireoak,humbletx#m#38000#333445555#5######'),
(3,15,'research#smith#john#productx###########'),
(3,15,'research#smith#john#producty###########'),
(3,15,'reverseengineering#jackson#camila#hindsight###########'),
(3,15,'reverseengineering#cuevas#hector#hindsight###########'),
(3,15,'research#wong#franklin#producty###########'),
(3,15,'research#wong#franklin#productz###########'),
(3,15,'research#wong#franklin#computerization###########'),
(3,15,'research#wong#franklin#reorganization###########'),
(3,15,'research#english#joyce#productx###########'),
(3,15,'research#english#joyce#producty###########'),
(3,15,'research#narayan#ramesh#productz###########'),
(3,15,'reverseengineering#smith#alicia#hindsight###########'),
(3,15,'headquarters#borg#james#reorganization###########'),
(3,15,'administration#wallace#jennifer#reorganization###########'),
(3,15,'administration#wallace#jennifer#newbenefits###########'),
(3,15,'administration#jabbar#ahmad#computerization###########'),
(3,15,'administration#jabbar#ahmad#newbenefits###########'),
(3,15,'administration#zelaya#alicia#computerization###########'),
(3,15,'administration#zelaya#alicia#newbenefits###########'),
(3,17,'123456789##############'),
(3,17,'333445555##############'),
(3,17,'453453453##############'),
(3,17,'666884444##############'),
(3,18,'james#borg#############'),
(3,19,'479000#55000#25000#36846.1538###########'),
(3,20,'133000#40000#25000#33250.0000###########'),
(3,21,'13##############'),
(3,22,'4##############'),
(3,23,'10##############'),
(3,24,'5#4#33250.0000############'),
(3,24,'9#5#39600.0000############'),
(3,24,'1#1#55000.0000############'),
(3,24,'4#3#31000.0000############'),
(3,25,'10#computerization#3############'),
(3,25,'55#hindsight#3############'),
(3,25,'30#newbenefits#3############'),
(3,25,'1#productx#2############'),
(3,25,'2#producty#3############'),
(3,25,'3#productz#2############'),
(3,25,'20#reorganization#3############'),
(3,26,'10#computerization#3############'),
(3,26,'55#hindsight#3############'),
(3,26,'30#newbenefits#3############'),
(3,26,'2#producty#3############'),
(3,26,'20#reorganization#3############'),
(3,27,'10#computerization#1############'),
(3,27,'55#hindsight#0############'),
(3,27,'30#newbenefits#0############'),
(3,27,'1#productx#2############'),
(3,27,'2#producty#3############'),
(3,27,'3#productz#2############'),
(3,27,'20#reorganization#1############'),
(3,28,'1#1#############'),
(3,28,'4#1#############'),
(3,29,'john#smith#123456789#1965-01-09#731fondren,houstontx#m#30000#333445555#5######'),
(3,29,'franklin#wong#333445555#1955-12-08#638voss,houstontx#m#40000#888665555#5######'),
(3,29,'joyce#english#453453453#1972-07-31#5631rice,houstontx#f#25000#333445555#5######'),
(3,29,'ramesh#narayan#666884444#1962-09-15#975fireoak,humbletx#m#38000#333445555#5######'),
(3,30,'john#smith#123456789#1965-01-09#731fondren,houstontx#m#30000#333445555#5#research#5#333445555#1988-05-22##'),
(3,30,'camila#jackson#163479608#1975-04-20#3830stellarfruit,tulsaok#f#37000#235711131#9#reverseengineering#9#235711131#2002-06-22##'),
(3,30,'hector#cuevas#235711131#1970-11-06#107fivefingerway,dallastx#m#31000#888665555#9#reverseengineering#9#235711131#2002-06-22##'),
(3,30,'franklin#wong#333445555#1955-12-08#638voss,houstontx#m#40000#888665555#5#research#5#333445555#1988-05-22##'),
(3,30,'heike#weiss#378990405#1966-11-13#219zoopalast,normanok#f#41000#235711131#9#reverseengineering#9#235711131#2002-06-22##'),
(3,30,'joyce#english#453453453#1972-07-31#5631rice,houstontx#f#25000#333445555#5#research#5#333445555#1988-05-22##'),
(3,30,'hiroto#watanabe#510176317#1961-11-17#606springtail,houstontx#m#38000#235711131#9#reverseengineering#9#235711131#2002-06-22##'),
(3,30,'ramesh#narayan#666884444#1962-09-15#975fireoak,humbletx#m#38000#333445555#5#research#5#333445555#1988-05-22##'),
(3,30,'alicia#smith#701294005#1967-03-19#2teleport,dallastx#f#51000#235711131#9#reverseengineering#9#235711131#2002-06-22##'),
(3,30,'james#borg#888665555#1937-11-10#450stone,houstontx#m#55000##1#headquarters#1#888665555#1981-06-19##'),
(3,30,'jennifer#wallace#987654321#1941-06-20#291berry,bellairetx#f#43000#888665555#4#administration#4#987654321#1995-01-01##'),
(3,30,'ahmad#jabbar#987987987#1969-03-29#980dallas,houstontx#m#25000#987654321#4#administration#4#987654321#1995-01-01##'),
(3,30,'alicia#zelaya#999887777#1968-01-19#3321castle,springtx#f#25000#987654321#4#administration#4#987654321#1995-01-01##'),
(3,31,'franklin#wong#1955-12-08############'),
(3,32,'john#smith#############'),
(3,32,'joyce#english#############'),
(3,34,'john#smith#############'),
(3,34,'joyce#english#############'),
(3,34,'ramesh#narayan#############'),
(3,35,'james#borg#############'),
(3,36,'john#smith#############'),
(3,36,'camila#jackson#############'),
(3,36,'heike#weiss#############'),
(3,36,'joyce#english#############'),
(3,36,'hiroto#watanabe#############'),
(3,36,'ramesh#narayan#############'),
(3,36,'alicia#smith#############'),
(3,36,'ahmad#jabbar#############'),
(3,36,'alicia#zelaya#############'),
(3,37,'camila#jackson#############'),
(3,37,'franklin#wong#############'),
(3,37,'heike#weiss#############'),
(3,37,'hiroto#watanabe#############'),
(3,37,'ramesh#narayan#############'),
(3,37,'alicia#smith#############'),
(3,37,'james#borg#############'),
(3,37,'jennifer#wallace#############'),
(3,40,'helloworld!##############'),
(3,41,'helloworld!##############'),
(3,42,'10##############'),
(3,43,'10#21#4############'),
(3,44,'john#smith#123456789#1965-01-09#731fondren,houstontx#m#30000#333445555#5######'),
(3,44,'camila#jackson#163479608#1975-04-20#3830stellarfruit,tulsaok#f#37000#235711131#9######'),
(3,44,'hector#cuevas#235711131#1970-11-06#107fivefingerway,dallastx#m#31000#888665555#9######'),
(3,44,'franklin#wong#333445555#1955-12-08#638voss,houstontx#m#40000#888665555#5######'),
(3,44,'heike#weiss#378990405#1966-11-13#219zoopalast,normanok#f#41000#235711131#9######'),
(3,44,'joyce#english#453453453#1972-07-31#5631rice,houstontx#f#25000#333445555#5######'),
(3,44,'hiroto#watanabe#510176317#1961-11-17#606springtail,houstontx#m#38000#235711131#9######'),
(3,44,'ramesh#narayan#666884444#1962-09-15#975fireoak,humbletx#m#38000#333445555#5######'),
(3,44,'alicia#smith#701294005#1967-03-19#2teleport,dallastx#f#51000#235711131#9######'),
(3,44,'james#borg#888665555#1937-11-10#450stone,houstontx#m#55000##1######'),
(3,44,'jennifer#wallace#987654321#1941-06-20#291berry,bellairetx#f#43000#888665555#4######'),
(3,44,'ahmad#jabbar#987987987#1969-03-29#980dallas,houstontx#m#25000#987654321#4######'),
(3,44,'alicia#zelaya#999887777#1968-01-19#3321castle,springtx#f#25000#987654321#4######'),
(3,50,'john#smith#731fondren,houstontx############'),
(3,50,'camila#jackson#3830stellarfruit,tulsaok############'),
(3,50,'hector#cuevas#107fivefingerway,dallastx############'),
(3,50,'franklin#wong#638voss,houstontx############'),
(3,50,'heike#weiss#219zoopalast,normanok############'),
(3,50,'joyce#english#5631rice,houstontx############'),
(3,50,'hiroto#watanabe#606springtail,houstontx############'),
(3,50,'ramesh#narayan#975fireoak,humbletx############'),
(3,50,'alicia#smith#2teleport,dallastx############'),
(3,50,'james#borg#450stone,houstontx############'),
(3,50,'jennifer#wallace#291berry,bellairetx############'),
(3,50,'ahmad#jabbar#980dallas,houstontx############'),
(3,50,'alicia#zelaya#3321castle,springtx############'),
(3,51,'smith#john#731fondren,houstontx############'),
(3,51,'jackson#camila#3830stellarfruit,tulsaok############'),
(3,51,'cuevas#hector#107fivefingerway,dallastx############'),
(3,51,'wong#franklin#638voss,houstontx############'),
(3,51,'weiss#heike#219zoopalast,normanok############'),
(3,51,'english#joyce#5631rice,houstontx############'),
(3,51,'watanabe#hiroto#606springtail,houstontx############'),
(3,51,'narayan#ramesh#975fireoak,humbletx############'),
(3,51,'smith#alicia#2teleport,dallastx############'),
(3,51,'borg#james#450stone,houstontx############'),
(3,51,'wallace#jennifer#291berry,bellairetx############'),
(3,51,'jabbar#ahmad#980dallas,houstontx############'),
(3,51,'zelaya#alicia#3321castle,springtx############'),
(3,52,'johnsmith#731fondren,houstontx#############'),
(3,52,'camilajackson#3830stellarfruit,tulsaok#############'),
(3,52,'hectorcuevas#107fivefingerway,dallastx#############'),
(3,52,'franklinwong#638voss,houstontx#############'),
(3,52,'heikeweiss#219zoopalast,normanok#############'),
(3,52,'joyceenglish#5631rice,houstontx#############'),
(3,52,'hirotowatanabe#606springtail,houstontx#############'),
(3,52,'rameshnarayan#975fireoak,humbletx#############'),
(3,52,'aliciasmith#2teleport,dallastx#############'),
(3,52,'jamesborg#450stone,houstontx#############'),
(3,52,'jenniferwallace#291berry,bellairetx#############'),
(3,52,'ahmadjabbar#980dallas,houstontx#############'),
(3,52,'aliciazelaya#3321castle,springtx#############'),
(3,53,'5##############'),
(3,53,'9##############'),
(3,53,'9##############'),
(3,53,'5##############'),
(3,53,'9##############'),
(3,53,'5##############'),
(3,53,'9##############'),
(3,53,'5##############'),
(3,53,'9##############'),
(3,53,'1##############'),
(3,53,'4##############'),
(3,53,'4##############'),
(3,53,'4##############'),
(3,54,'5##############'),
(3,54,'9##############'),
(3,54,'1##############'),
(3,54,'4##############'),
(3,55,'30000#5#############'),
(3,55,'37000#9#############'),
(3,55,'31000#9#############'),
(3,55,'40000#5#############'),
(3,55,'41000#9#############'),
(3,55,'25000#5#############'),
(3,55,'38000#9#############'),
(3,55,'38000#5#############'),
(3,55,'51000#9#############'),
(3,55,'55000#1#############'),
(3,55,'43000#4#############'),
(3,55,'25000#4#############'),
(3,55,'25000#4#############'),
(3,56,'30000#5#############'),
(3,56,'37000#9#############'),
(3,56,'31000#9#############'),
(3,56,'40000#5#############'),
(3,56,'41000#9#############'),
(3,56,'25000#5#############'),
(3,56,'38000#9#############'),
(3,56,'38000#5#############'),
(3,56,'51000#9#############'),
(3,56,'55000#1#############'),
(3,56,'43000#4#############'),
(3,56,'25000#4#############'),
(3,60,'john#smith#731fondren,houstontx############'),
(3,60,'franklin#wong#638voss,houstontx############'),
(3,60,'joyce#english#5631rice,houstontx############'),
(3,60,'ramesh#narayan#975fireoak,humbletx############'),
(3,61,'camila#jackson#3830stellarfruit,tulsaok############'),
(3,61,'hector#cuevas#107fivefingerway,dallastx############'),
(3,61,'heike#weiss#219zoopalast,normanok############'),
(3,61,'hiroto#watanabe#606springtail,houstontx############'),
(3,61,'alicia#smith#2teleport,dallastx############'),
(3,61,'james#borg#450stone,houstontx############'),
(3,61,'jennifer#wallace#291berry,bellairetx############'),
(3,61,'ahmad#jabbar#980dallas,houstontx############'),
(3,61,'alicia#zelaya#3321castle,springtx############'),
(3,62,'camila#jackson#3830stellarfruit,tulsaok############'),
(3,62,'hector#cuevas#107fivefingerway,dallastx############'),
(3,62,'franklin#wong#638voss,houstontx############'),
(3,62,'heike#weiss#219zoopalast,normanok############'),
(3,62,'hiroto#watanabe#606springtail,houstontx############'),
(3,62,'ramesh#narayan#975fireoak,humbletx############'),
(3,62,'alicia#smith#2teleport,dallastx############'),
(3,62,'james#borg#450stone,houstontx############'),
(3,62,'jennifer#wallace#291berry,bellairetx############'),
(3,63,'john#smith#731fondren,houstontx############'),
(3,63,'camila#jackson#3830stellarfruit,tulsaok############'),
(3,63,'hector#cuevas#107fivefingerway,dallastx############'),
(3,63,'franklin#wong#638voss,houstontx############'),
(3,63,'heike#weiss#219zoopalast,normanok############'),
(3,63,'joyce#english#5631rice,houstontx############'),
(3,63,'hiroto#watanabe#606springtail,houstontx############'),
(3,63,'ramesh#narayan#975fireoak,humbletx############'),
(3,63,'alicia#smith#2teleport,dallastx############'),
(3,63,'james#borg#450stone,houstontx############'),
(3,63,'jennifer#wallace#291berry,bellairetx############'),
(3,64,'franklin#wong#638voss,houstontx############'),
(3,64,'ramesh#narayan#975fireoak,humbletx############'),
(3,65,'camila#jackson#3830stellarfruit,tulsaok#1975-04-20###########'),
(3,65,'hector#cuevas#107fivefingerway,dallastx#1970-11-06###########'),
(3,65,'joyce#english#5631rice,houstontx#1972-07-31###########'),
(3,65,'ahmad#jabbar#980dallas,houstontx#1969-03-29###########'),
(3,65,'alicia#zelaya#3321castle,springtx#1968-01-19###########'),
(3,66,'john#smith#731fondren,houstontx#1965-01-09###########'),
(3,66,'heike#weiss#219zoopalast,normanok#1966-11-13###########'),
(3,66,'alicia#smith#2teleport,dallastx#1967-03-19###########'),
(3,66,'ahmad#jabbar#980dallas,houstontx#1969-03-29###########'),
(3,66,'alicia#zelaya#3321castle,springtx#1968-01-19###########'),
(3,67,'john#smith#731fondren,houstontx############'),
(3,67,'camila#jackson#3830stellarfruit,tulsaok############'),
(3,67,'hector#cuevas#107fivefingerway,dallastx############'),
(3,67,'franklin#wong#638voss,houstontx############'),
(3,67,'heike#weiss#219zoopalast,normanok############'),
(3,67,'joyce#english#5631rice,houstontx############'),
(3,67,'hiroto#watanabe#606springtail,houstontx############'),
(3,67,'ramesh#narayan#975fireoak,humbletx############'),
(3,67,'alicia#smith#2teleport,dallastx############'),
(3,67,'james#borg#450stone,houstontx############'),
(3,67,'jennifer#wallace#291berry,bellairetx############'),
(3,67,'ahmad#jabbar#980dallas,houstontx############'),
(3,67,'alicia#zelaya#3321castle,springtx############'),
(3,68,'john#smith#731fondren,houstontx############'),
(3,68,'camila#jackson#3830stellarfruit,tulsaok############'),
(3,68,'hector#cuevas#107fivefingerway,dallastx############'),
(3,68,'franklin#wong#638voss,houstontx############'),
(3,68,'heike#weiss#219zoopalast,normanok############'),
(3,68,'joyce#english#5631rice,houstontx############'),
(3,68,'hiroto#watanabe#606springtail,houstontx############'),
(3,68,'ramesh#narayan#975fireoak,humbletx############'),
(3,68,'alicia#smith#2teleport,dallastx############'),
(3,68,'james#borg#450stone,houstontx############'),
(3,68,'jennifer#wallace#291berry,bellairetx############'),
(3,68,'ahmad#jabbar#980dallas,houstontx############'),
(3,68,'alicia#zelaya#3321castle,springtx############'),
(3,69,'john#731fondren,houstontx#############'),
(3,69,'camila#3830stellarfruit,tulsaok#############'),
(3,69,'hector#107fivefingerway,dallastx#############'),
(3,69,'franklin#638voss,houstontx#############'),
(3,69,'heike#219zoopalast,normanok#############'),
(3,69,'joyce#5631rice,houstontx#############'),
(3,69,'hiroto#606springtail,houstontx#############'),
(3,69,'ramesh#975fireoak,humbletx#############'),
(3,69,'alicia#2teleport,dallastx#############'),
(3,69,'james#450stone,houstontx#############'),
(3,69,'jennifer#291berry,bellairetx#############'),
(3,69,'ahmad#980dallas,houstontx#############'),
(3,69,'alicia#3321castle,springtx#############'),
(3,70,'john#smith#731fondren,houstontx############'),
(3,70,'camila#jackson#3830stellarfruit,tulsaok############'),
(3,70,'hector#cuevas#107fivefingerway,dallastx############'),
(3,70,'franklin#wong#638voss,houstontx############'),
(3,70,'heike#weiss#219zoopalast,normanok############'),
(3,70,'joyce#english#5631rice,houstontx############'),
(3,70,'hiroto#watanabe#606springtail,houstontx############'),
(3,70,'ramesh#narayan#975fireoak,humbletx############'),
(3,70,'alicia#smith#2teleport,dallastx############'),
(3,70,'james#borg#450stone,houstontx############'),
(3,70,'jennifer#wallace#291berry,bellairetx############'),
(3,70,'ahmad#jabbar#980dallas,houstontx############'),
(3,70,'alicia#zelaya#3321castle,springtx############'),
(3,71,'john#smith#731fondren,houstontx############'),
(3,71,'franklin#wong#638voss,houstontx############'),
(3,71,'joyce#english#5631rice,houstontx############'),
(3,71,'hiroto#watanabe#606springtail,houstontx############'),
(3,71,'james#borg#450stone,houstontx############'),
(3,71,'ahmad#jabbar#980dallas,houstontx############'),
(3,72,'hector#cuevas#107fivefingerway,dallastx############'),
(3,72,'alicia#smith#2teleport,dallastx############'),
(3,72,'ahmad#jabbar#980dallas,houstontx############'),
(3,73,'john#smith#731fondren,houstontx############'),
(3,73,'joyce#english#5631rice,houstontx############'),
(3,73,'james#borg#450stone,houstontx############'),
(3,73,'jennifer#wallace#291berry,bellairetx############'),
(3,74,'ramesh#narayan#975fireoak,humbletx############'),
(3,74,'alicia#zelaya#3321castle,springtx############'),
(3,75,'ramesh#narayan#975fireoak,humbletx############'),
(3,80,'john#smith#33000.000000000############'),
(3,80,'franklin#wong#44000.000000000############'),
(3,80,'joyce#english#27500.000000000############'),
(3,80,'ramesh#narayan#41800.000000000############'),
(3,81,'133000##############'),
(3,82,'25000#40000#############'),
(3,83,'10##############'),
(3,84,'4##############'),
(3,85,'3##############'),
(3,86,'9##############'),
(3,87,'13##############'),
(3,88,'5#25000#33250.0000#40000###########'),
(3,88,'9#31000#39600.0000#51000###########'),
(3,88,'1#55000#55000.0000#55000###########'),
(3,88,'4#25000#31000.0000#43000###########'),
(3,89,'1#55000#55000.0000#55000###########'),
(3,89,'4#25000#31000.0000#43000###########'),
(3,100,'5#3#############'),
(3,100,'9#5#############'),
(3,100,'1#1#############'),
(3,100,'4#1#############'),
(3,101,'5#3#############'),
(3,101,'9#5#############'),
(3,101,'4#1#############'),
(3,102,'1##############'),
(3,102,'4##############'),
(3,103,'1#1#############'),
(3,103,'4#1#############'),
(3,104,'john#smith#731fondren,houstontx############'),
(3,104,'franklin#wong#638voss,houstontx############'),
(3,105,'franklin#wong#638voss,houstontx############'),
(3,105,'ramesh#narayan#975fireoak,humbletx############'),
(3,105,'james#borg#450stone,houstontx############'),
(3,105,'jennifer#wallace#291berry,bellairetx############'),
(3,106,'123456789##############'),
(3,106,'163479608##############'),
(3,106,'235711131##############'),
(3,106,'333445555##############'),
(3,106,'378990405##############'),
(3,106,'510176317##############'),
(3,106,'666884444##############'),
(3,106,'701294005##############'),
(3,106,'888665555##############'),
(3,106,'987654321##############'),
(3,107,'333445555##############'),
(3,107,'888665555##############'),
(3,107,'987654321##############'),
(3,108,'123456789##############'),
(3,108,'163479608##############'),
(3,108,'235711131##############'),
(3,108,'378990405##############'),
(3,108,'510176317##############'),
(3,108,'666884444##############'),
(3,108,'701294005##############'),
(3,120,'john#smith#731fondren,houstontx#5#9#reverseengineering#########'),
(3,120,'john#smith#731fondren,houstontx#5#5#research#########'),
(3,120,'john#smith#731fondren,houstontx#5#1#headquarters#########'),
(3,120,'john#smith#731fondren,houstontx#5#4#administration#########'),
(3,120,'camila#jackson#3830stellarfruit,tulsaok#9#9#reverseengineering#########'),
(3,120,'camila#jackson#3830stellarfruit,tulsaok#9#5#research#########'),
(3,120,'camila#jackson#3830stellarfruit,tulsaok#9#1#headquarters#########'),
(3,120,'camila#jackson#3830stellarfruit,tulsaok#9#4#administration#########'),
(3,120,'hector#cuevas#107fivefingerway,dallastx#9#9#reverseengineering#########'),
(3,120,'hector#cuevas#107fivefingerway,dallastx#9#5#research#########'),
(3,120,'hector#cuevas#107fivefingerway,dallastx#9#1#headquarters#########'),
(3,120,'hector#cuevas#107fivefingerway,dallastx#9#4#administration#########'),
(3,120,'franklin#wong#638voss,houstontx#5#9#reverseengineering#########'),
(3,120,'franklin#wong#638voss,houstontx#5#5#research#########'),
(3,120,'franklin#wong#638voss,houstontx#5#1#headquarters#########'),
(3,120,'franklin#wong#638voss,houstontx#5#4#administration#########'),
(3,120,'heike#weiss#219zoopalast,normanok#9#9#reverseengineering#########'),
(3,120,'heike#weiss#219zoopalast,normanok#9#5#research#########'),
(3,120,'heike#weiss#219zoopalast,normanok#9#1#headquarters#########'),
(3,120,'heike#weiss#219zoopalast,normanok#9#4#administration#########'),
(3,120,'joyce#english#5631rice,houstontx#5#9#reverseengineering#########'),
(3,120,'joyce#english#5631rice,houstontx#5#5#research#########'),
(3,120,'joyce#english#5631rice,houstontx#5#1#headquarters#########'),
(3,120,'joyce#english#5631rice,houstontx#5#4#administration#########'),
(3,120,'hiroto#watanabe#606springtail,houstontx#9#9#reverseengineering#########'),
(3,120,'hiroto#watanabe#606springtail,houstontx#9#5#research#########'),
(3,120,'hiroto#watanabe#606springtail,houstontx#9#1#headquarters#########'),
(3,120,'hiroto#watanabe#606springtail,houstontx#9#4#administration#########'),
(3,120,'ramesh#narayan#975fireoak,humbletx#5#9#reverseengineering#########'),
(3,120,'ramesh#narayan#975fireoak,humbletx#5#5#research#########'),
(3,120,'ramesh#narayan#975fireoak,humbletx#5#1#headquarters#########'),
(3,120,'ramesh#narayan#975fireoak,humbletx#5#4#administration#########'),
(3,120,'alicia#smith#2teleport,dallastx#9#9#reverseengineering#########'),
(3,120,'alicia#smith#2teleport,dallastx#9#5#research#########'),
(3,120,'alicia#smith#2teleport,dallastx#9#1#headquarters#########'),
(3,120,'alicia#smith#2teleport,dallastx#9#4#administration#########'),
(3,120,'james#borg#450stone,houstontx#1#9#reverseengineering#########'),
(3,120,'james#borg#450stone,houstontx#1#5#research#########'),
(3,120,'james#borg#450stone,houstontx#1#1#headquarters#########'),
(3,120,'james#borg#450stone,houstontx#1#4#administration#########'),
(3,120,'jennifer#wallace#291berry,bellairetx#4#9#reverseengineering#########'),
(3,120,'jennifer#wallace#291berry,bellairetx#4#5#research#########'),
(3,120,'jennifer#wallace#291berry,bellairetx#4#1#headquarters#########'),
(3,120,'jennifer#wallace#291berry,bellairetx#4#4#administration#########'),
(3,120,'ahmad#jabbar#980dallas,houstontx#4#9#reverseengineering#########'),
(3,120,'ahmad#jabbar#980dallas,houstontx#4#5#research#########'),
(3,120,'ahmad#jabbar#980dallas,houstontx#4#1#headquarters#########'),
(3,120,'ahmad#jabbar#980dallas,houstontx#4#4#administration#########'),
(3,120,'alicia#zelaya#3321castle,springtx#4#9#reverseengineering#########'),
(3,120,'alicia#zelaya#3321castle,springtx#4#5#research#########'),
(3,120,'alicia#zelaya#3321castle,springtx#4#1#headquarters#########'),
(3,120,'alicia#zelaya#3321castle,springtx#4#4#administration#########'),
(3,121,'john#smith#731fondren,houstontx#research#5##########'),
(3,121,'camila#jackson#3830stellarfruit,tulsaok#reverseengineering#9##########'),
(3,121,'hector#cuevas#107fivefingerway,dallastx#reverseengineering#9##########'),
(3,121,'franklin#wong#638voss,houstontx#research#5##########'),
(3,121,'heike#weiss#219zoopalast,normanok#reverseengineering#9##########'),
(3,121,'joyce#english#5631rice,houstontx#research#5##########'),
(3,121,'hiroto#watanabe#606springtail,houstontx#reverseengineering#9##########'),
(3,121,'ramesh#narayan#975fireoak,humbletx#research#5##########'),
(3,121,'alicia#smith#2teleport,dallastx#reverseengineering#9##########'),
(3,121,'james#borg#450stone,houstontx#headquarters#1##########'),
(3,121,'jennifer#wallace#291berry,bellairetx#administration#4##########'),
(3,121,'ahmad#jabbar#980dallas,houstontx#administration#4##########'),
(3,121,'alicia#zelaya#3321castle,springtx#administration#4##########'),
(3,122,'john#smith#731fondren,houstontx#research#5##########'),
(3,122,'camila#jackson#3830stellarfruit,tulsaok#reverseengineering#9##########'),
(3,122,'hector#cuevas#107fivefingerway,dallastx#reverseengineering#9##########'),
(3,122,'franklin#wong#638voss,houstontx#research#5##########'),
(3,122,'heike#weiss#219zoopalast,normanok#reverseengineering#9##########'),
(3,122,'joyce#english#5631rice,houstontx#research#5##########'),
(3,122,'hiroto#watanabe#606springtail,houstontx#reverseengineering#9##########'),
(3,122,'ramesh#narayan#975fireoak,humbletx#research#5##########'),
(3,122,'alicia#smith#2teleport,dallastx#reverseengineering#9##########'),
(3,122,'james#borg#450stone,houstontx#headquarters#1##########'),
(3,122,'jennifer#wallace#291berry,bellairetx#administration#4##########'),
(3,122,'ahmad#jabbar#980dallas,houstontx#administration#4##########'),
(3,122,'alicia#zelaya#3321castle,springtx#administration#4##########'),
(3,123,'john#smith#731fondren,houstontx#research#5##########'),
(3,123,'camila#jackson#3830stellarfruit,tulsaok#reverseengineering#9##########'),
(3,123,'hector#cuevas#107fivefingerway,dallastx#reverseengineering#9##########'),
(3,123,'franklin#wong#638voss,houstontx#research#5##########'),
(3,123,'heike#weiss#219zoopalast,normanok#reverseengineering#9##########'),
(3,123,'joyce#english#5631rice,houstontx#research#5##########'),
(3,123,'hiroto#watanabe#606springtail,houstontx#reverseengineering#9##########'),
(3,123,'ramesh#narayan#975fireoak,humbletx#research#5##########'),
(3,123,'alicia#smith#2teleport,dallastx#reverseengineering#9##########'),
(3,123,'james#borg#450stone,houstontx#headquarters#1##########'),
(3,123,'jennifer#wallace#291berry,bellairetx#administration#4##########'),
(3,123,'ahmad#jabbar#980dallas,houstontx#administration#4##########'),
(3,123,'alicia#zelaya#3321castle,springtx#administration#4##########'),
(3,124,'john#smith#731fondren,houstontx#333445555#franklin#wong#########'),
(3,124,'camila#jackson#3830stellarfruit,tulsaok#235711131#hector#cuevas#########'),
(3,124,'hector#cuevas#107fivefingerway,dallastx#888665555#james#borg#########'),
(3,124,'franklin#wong#638voss,houstontx#888665555#james#borg#########'),
(3,124,'heike#weiss#219zoopalast,normanok#235711131#hector#cuevas#########'),
(3,124,'joyce#english#5631rice,houstontx#333445555#franklin#wong#########'),
(3,124,'hiroto#watanabe#606springtail,houstontx#235711131#hector#cuevas#########'),
(3,124,'ramesh#narayan#975fireoak,humbletx#333445555#franklin#wong#########'),
(3,124,'alicia#smith#2teleport,dallastx#235711131#hector#cuevas#########'),
(3,124,'james#borg#450stone,houstontx############'),
(3,124,'jennifer#wallace#291berry,bellairetx#888665555#james#borg#########'),
(3,124,'ahmad#jabbar#980dallas,houstontx#987654321#jennifer#wallace#########'),
(3,124,'alicia#zelaya#3321castle,springtx#987654321#jennifer#wallace#########'),
(3,125,'alice#1988-12-30#john#smith###########'),
(3,125,'elizabeth#1967-05-05#john#smith###########'),
(3,125,'michael#1988-01-04#john#smith###########'),
(3,125,'##camila#jackson###########'),
(3,125,'##hector#cuevas###########'),
(3,125,'alice#1986-04-04#franklin#wong###########'),
(3,125,'joy#1958-05-03#franklin#wong###########'),
(3,125,'theodore#1983-10-25#franklin#wong###########'),
(3,125,'ariel#1989-05-25#heike#weiss###########'),
(3,125,'florence#1966-01-25#heike#weiss###########'),
(3,125,'##joyce#english###########'),
(3,125,'##hiroto#watanabe###########'),
(3,125,'##ramesh#narayan###########'),
(3,125,'##alicia#smith###########'),
(3,125,'##james#borg###########'),
(3,125,'abner#1942-02-28#jennifer#wallace###########'),
(3,125,'##ahmad#jabbar###########'),
(3,125,'##alicia#zelaya###########'),
(3,126,'james#borg#headquarters#1###########'),
(3,126,'jennifer#wallace#administration#4###########'),
(3,126,'franklin#wong#research#5###########'),
(3,126,'hector#cuevas#reverseengineering#9###########'),
(3,127,'john#smith#5############'),
(3,127,'camila#jackson#9############'),
(3,127,'hector#cuevas#9#reverseengineering###########'),
(3,127,'franklin#wong#5#research###########'),
(3,127,'heike#weiss#9############'),
(3,127,'joyce#english#5############'),
(3,127,'hiroto#watanabe#9############'),
(3,127,'ramesh#narayan#5############'),
(3,127,'alicia#smith#9############'),
(3,127,'james#borg#1#headquarters###########'),
(3,127,'jennifer#wallace#4#administration###########'),
(3,127,'ahmad#jabbar#4############'),
(3,127,'alicia#zelaya#4############'),
(3,128,'john#smith#731fondren,houstontx#reorganization#houston##########'),
(3,128,'john#smith#731fondren,houstontx#productz#houston##########'),
(3,128,'hector#cuevas#107fivefingerway,dallastx#hindsight#dallas##########'),
(3,128,'franklin#wong#638voss,houstontx#reorganization#houston##########'),
(3,128,'franklin#wong#638voss,houstontx#productz#houston##########'),
(3,128,'joyce#english#5631rice,houstontx#reorganization#houston##########'),
(3,128,'joyce#english#5631rice,houstontx#productz#houston##########'),
(3,128,'hiroto#watanabe#606springtail,houstontx#reorganization#houston##########'),
(3,128,'hiroto#watanabe#606springtail,houstontx#productz#houston##########'),
(3,128,'alicia#smith#2teleport,dallastx#hindsight#dallas##########'),
(3,128,'james#borg#450stone,houstontx#reorganization#houston##########'),
(3,128,'james#borg#450stone,houstontx#productz#houston##########'),
(3,128,'jennifer#wallace#291berry,bellairetx#productx#bellaire##########'),
(3,128,'ahmad#jabbar#980dallas,houstontx#hindsight#dallas##########'),
(3,128,'ahmad#jabbar#980dallas,houstontx#reorganization#houston##########'),
(3,128,'ahmad#jabbar#980dallas,houstontx#productz#houston##########'),
(3,129,'john#smith#1965-01-09#hector#cuevas#1970-11-06#########'),
(3,129,'franklin#wong#1955-12-08#hector#cuevas#1970-11-06#########'),
(3,129,'heike#weiss#1966-11-13#hector#cuevas#1970-11-06#########'),
(3,129,'hiroto#watanabe#1961-11-17#hector#cuevas#1970-11-06#########'),
(3,129,'ramesh#narayan#1962-09-15#hector#cuevas#1970-11-06#########'),
(3,129,'alicia#smith#1967-03-19#hector#cuevas#1970-11-06#########'),
(3,129,'james#borg#1937-11-10#hector#cuevas#1970-11-06#########'),
(3,129,'james#borg#1937-11-10#franklin#wong#1955-12-08#########'),
(3,129,'james#borg#1937-11-10#jennifer#wallace#1941-06-20#########'),
(3,129,'jennifer#wallace#1941-06-20#hector#cuevas#1970-11-06#########'),
(3,129,'jennifer#wallace#1941-06-20#franklin#wong#1955-12-08#########'),
(3,129,'ahmad#jabbar#1969-03-29#hector#cuevas#1970-11-06#########'),
(3,129,'alicia#zelaya#1968-01-19#hector#cuevas#1970-11-06#########'),
(4,0,'1965-01-09#731fondren,houstontx#############'),
(4,1,'john#smith#731fondren,houstontx############'),
(4,1,'franklin#wong#638voss,houstontx############'),
(4,1,'joyce#english#5631rice,houstontx############'),
(4,1,'ramesh#narayan#975fireoak,humbletx############'),
(4,2,'10#4#wallace#291berry,bellairetx#1941-06-20##########'),
(4,2,'30#4#wallace#291berry,bellairetx#1941-06-20##########'),
(4,4,'1##############'),
(4,4,'2##############'),
(4,5,'john#smith#############'),
(4,5,'franklin#wong#############'),
(4,6,'joyce#english#############'),
(4,6,'ramesh#narayan#############'),
(4,6,'james#borg#############'),
(4,6,'ahmad#jabbar#############'),
(4,6,'alicia#zelaya#############'),
(4,7,'jennifer#wallace#############'),
(4,7,'franklin#wong#############'),
(4,8,'john#smith#franklin#wong###########'),
(4,8,'franklin#wong#james#borg###########'),
(4,8,'joyce#english#franklin#wong###########'),
(4,8,'ramesh#narayan#franklin#wong###########'),
(4,8,'james#borg#############'),
(4,8,'jennifer#wallace#james#borg###########'),
(4,8,'ahmad#jabbar#jennifer#wallace###########'),
(4,8,'alicia#zelaya#jennifer#wallace###########'),
(4,9,'123456789##############'),
(4,9,'333445555##############'),
(4,9,'453453453##############'),
(4,9,'666884444##############'),
(4,9,'888665555##############'),
(4,9,'987654321##############'),
(4,9,'987987987##############'),
(4,9,'999887777##############'),
(4,10,'123456789#research#############'),
(4,10,'123456789#headquarters#############'),
(4,10,'123456789#administration#############'),
(4,10,'333445555#research#############'),
(4,10,'333445555#headquarters#############'),
(4,10,'333445555#administration#############'),
(4,10,'453453453#research#############'),
(4,10,'453453453#headquarters#############'),
(4,10,'453453453#administration#############'),
(4,10,'666884444#research#############'),
(4,10,'666884444#headquarters#############'),
(4,10,'666884444#administration#############'),
(4,10,'888665555#research#############'),
(4,10,'888665555#headquarters#############'),
(4,10,'888665555#administration#############'),
(4,10,'987654321#research#############'),
(4,10,'987654321#headquarters#############'),
(4,10,'987654321#administration#############'),
(4,10,'987987987#research#############'),
(4,10,'987987987#headquarters#############'),
(4,10,'987987987#administration#############'),
(4,10,'999887777#research#############'),
(4,10,'999887777#headquarters#############'),
(4,10,'999887777#administration#############'),
(4,11,'36000##############'),
(4,11,'37000##############'),
(4,11,'25000##############'),
(4,11,'38000##############'),
(4,11,'55000##############'),
(4,11,'46000##############'),
(4,11,'34000##############'),
(4,11,'31000##############'),
(4,12,'john#smith#############'),
(4,12,'franklin#wong#############'),
(4,12,'joyce#english#############'),
(4,12,'james#borg#############'),
(4,12,'ahmad#jabbar#############'),
(4,13,'franklin#wong#37000.00############'),
(4,13,'ramesh#narayan#38000.00############'),
(4,13,'james#borg#55000.00############'),
(4,13,'jennifer#wallace#46000.00############'),
(4,13,'ahmad#jabbar#34000.00############'),
(4,13,'alicia#zelaya#31000.00############'),
(4,13,'john#smith#39600.00############'),
(4,13,'joyce#english#27500.00############'),
(4,14,'john#smith#123456789#1965-01-09#731fondren,houstontx#m#36000#333445555#5######'),
(4,14,'franklin#wong#333445555#1955-12-08#638voss,houstontx#m#37000#888665555#5######'),
(4,14,'ramesh#narayan#666884444#1962-09-15#975fireoak,humbletx#m#38000#333445555#5######'),
(4,15,'research#smith#john#productx###########'),
(4,15,'research#smith#john#producty###########'),
(4,15,'research#wong#franklin#producty###########'),
(4,15,'research#wong#franklin#productz###########'),
(4,15,'research#wong#franklin#computerization###########'),
(4,15,'research#wong#franklin#reorganization###########'),
(4,15,'research#english#joyce#productx###########'),
(4,15,'research#english#joyce#producty###########'),
(4,15,'research#narayan#ramesh#productz###########'),
(4,15,'headquarters#borg#james#reorganization###########'),
(4,15,'administration#wallace#jennifer#reorganization###########'),
(4,15,'administration#wallace#jennifer#newbenefits###########'),
(4,15,'administration#jabbar#ahmad#computerization###########'),
(4,15,'administration#jabbar#ahmad#newbenefits###########'),
(4,15,'administration#zelaya#alicia#computerization###########'),
(4,15,'administration#zelaya#alicia#newbenefits###########'),
(4,17,'123456789##############'),
(4,17,'333445555##############'),
(4,17,'453453453##############'),
(4,17,'666884444##############'),
(4,18,'james#borg#############'),
(4,19,'302000#55000#25000#37750.0000###########'),
(4,20,'136000#38000#25000#34000.0000###########'),
(4,21,'8##############'),
(4,22,'4##############'),
(4,23,'8##############'),
(4,24,'5#4#34000.0000############'),
(4,24,'1#1#55000.0000############'),
(4,24,'4#3#37000.0000############'),
(4,25,'10#computerization#3############'),
(4,25,'30#newbenefits#3############'),
(4,25,'1#productx#2############'),
(4,25,'2#producty#3############'),
(4,25,'3#productz#2############'),
(4,25,'20#reorganization#3############'),
(4,26,'10#computerization#3############'),
(4,26,'30#newbenefits#3############'),
(4,26,'2#producty#3############'),
(4,26,'20#reorganization#3############'),
(4,27,'10#computerization#1############'),
(4,27,'30#newbenefits#0############'),
(4,27,'1#productx#2############'),
(4,27,'2#producty#3############'),
(4,27,'3#productz#2############'),
(4,27,'20#reorganization#1############'),
(4,28,'1#1#############'),
(4,28,'4#3#############'),
(4,29,'john#smith#123456789#1965-01-09#731fondren,houstontx#m#36000#333445555#5######'),
(4,29,'franklin#wong#333445555#1955-12-08#638voss,houstontx#m#37000#888665555#5######'),
(4,29,'joyce#english#453453453#1972-07-31#5631rice,houstontx#f#25000#333445555#5######'),
(4,29,'ramesh#narayan#666884444#1962-09-15#975fireoak,humbletx#m#38000#333445555#5######'),
(4,30,'john#smith#123456789#1965-01-09#731fondren,houstontx#m#36000#333445555#5#research#5#333445555#1988-05-22##'),
(4,30,'franklin#wong#333445555#1955-12-08#638voss,houstontx#m#37000#888665555#5#research#5#333445555#1988-05-22##'),
(4,30,'joyce#english#453453453#1972-07-31#5631rice,houstontx#f#25000#333445555#5#research#5#333445555#1988-05-22##'),
(4,30,'ramesh#narayan#666884444#1962-09-15#975fireoak,humbletx#m#38000#333445555#5#research#5#333445555#1988-05-22##'),
(4,30,'james#borg#888665555#1937-11-10#450stone,houstontx#m#55000##1#headquarters#1#888665555#1981-06-19##'),
(4,30,'jennifer#wallace#987654321#1941-06-20#291berry,bellairetx#f#46000#888665555#4#administration#4#987654321#1995-01-01##'),
(4,30,'ahmad#jabbar#987987987#1969-03-29#980dallas,houstontx#m#34000#987654321#4#administration#4#987654321#1995-01-01##'),
(4,30,'alicia#zelaya#999887777#1968-01-19#3321castle,springtx#f#31000#987654321#4#administration#4#987654321#1995-01-01##'),
(4,31,'franklin#wong#1955-12-08############'),
(4,32,'john#smith#############'),
(4,32,'joyce#english#############'),
(4,34,'john#smith#############'),
(4,34,'joyce#english#############'),
(4,34,'ramesh#narayan#############'),
(4,35,'james#borg#############'),
(4,36,'john#smith#############'),
(4,36,'joyce#english#############'),
(4,36,'ramesh#narayan#############'),
(4,36,'ahmad#jabbar#############'),
(4,36,'alicia#zelaya#############'),
(4,37,'john#smith#############'),
(4,37,'franklin#wong#############'),
(4,37,'ramesh#narayan#############'),
(4,37,'james#borg#############'),
(4,37,'jennifer#wallace#############'),
(4,40,'helloworld!##############'),
(4,41,'helloworld!##############'),
(4,42,'10##############'),
(4,43,'10#21#4############'),
(4,44,'john#smith#123456789#1965-01-09#731fondren,houstontx#m#36000#333445555#5######'),
(4,44,'franklin#wong#333445555#1955-12-08#638voss,houstontx#m#37000#888665555#5######'),
(4,44,'joyce#english#453453453#1972-07-31#5631rice,houstontx#f#25000#333445555#5######'),
(4,44,'ramesh#narayan#666884444#1962-09-15#975fireoak,humbletx#m#38000#333445555#5######'),
(4,44,'james#borg#888665555#1937-11-10#450stone,houstontx#m#55000##1######'),
(4,44,'jennifer#wallace#987654321#1941-06-20#291berry,bellairetx#f#46000#888665555#4######'),
(4,44,'ahmad#jabbar#987987987#1969-03-29#980dallas,houstontx#m#34000#987654321#4######'),
(4,44,'alicia#zelaya#999887777#1968-01-19#3321castle,springtx#f#31000#987654321#4######'),
(4,50,'john#smith#731fondren,houstontx############'),
(4,50,'franklin#wong#638voss,houstontx############'),
(4,50,'joyce#english#5631rice,houstontx############'),
(4,50,'ramesh#narayan#975fireoak,humbletx############'),
(4,50,'james#borg#450stone,houstontx############'),
(4,50,'jennifer#wallace#291berry,bellairetx############'),
(4,50,'ahmad#jabbar#980dallas,houstontx############'),
(4,50,'alicia#zelaya#3321castle,springtx############'),
(4,51,'smith#john#731fondren,houstontx############'),
(4,51,'wong#franklin#638voss,houstontx############'),
(4,51,'english#joyce#5631rice,houstontx############'),
(4,51,'narayan#ramesh#975fireoak,humbletx############'),
(4,51,'borg#james#450stone,houstontx############'),
(4,51,'wallace#jennifer#291berry,bellairetx############'),
(4,51,'jabbar#ahmad#980dallas,houstontx############'),
(4,51,'zelaya#alicia#3321castle,springtx############'),
(4,52,'johnsmith#731fondren,houstontx#############'),
(4,52,'franklinwong#638voss,houstontx#############'),
(4,52,'joyceenglish#5631rice,houstontx#############'),
(4,52,'rameshnarayan#975fireoak,humbletx#############'),
(4,52,'jamesborg#450stone,houstontx#############'),
(4,52,'jenniferwallace#291berry,bellairetx#############'),
(4,52,'ahmadjabbar#980dallas,houstontx#############'),
(4,52,'aliciazelaya#3321castle,springtx#############'),
(4,53,'5##############'),
(4,53,'5##############'),
(4,53,'5##############'),
(4,53,'5##############'),
(4,53,'1##############'),
(4,53,'4##############'),
(4,53,'4##############'),
(4,53,'4##############'),
(4,54,'5##############'),
(4,54,'1##############'),
(4,54,'4##############'),
(4,55,'36000#5#############'),
(4,55,'37000#5#############'),
(4,55,'25000#5#############'),
(4,55,'38000#5#############'),
(4,55,'55000#1#############'),
(4,55,'46000#4#############'),
(4,55,'34000#4#############'),
(4,55,'31000#4#############'),
(4,56,'36000#5#############'),
(4,56,'37000#5#############'),
(4,56,'25000#5#############'),
(4,56,'38000#5#############'),
(4,56,'55000#1#############'),
(4,56,'46000#4#############'),
(4,56,'34000#4#############'),
(4,56,'31000#4#############'),
(4,60,'john#smith#731fondren,houstontx############'),
(4,60,'franklin#wong#638voss,houstontx############'),
(4,60,'joyce#english#5631rice,houstontx############'),
(4,60,'ramesh#narayan#975fireoak,humbletx############'),
(4,61,'james#borg#450stone,houstontx############'),
(4,61,'jennifer#wallace#291berry,bellairetx############'),
(4,61,'ahmad#jabbar#980dallas,houstontx############'),
(4,61,'alicia#zelaya#3321castle,springtx############'),
(4,62,'john#smith#731fondren,houstontx############'),
(4,62,'franklin#wong#638voss,houstontx############'),
(4,62,'ramesh#narayan#975fireoak,humbletx############'),
(4,62,'james#borg#450stone,houstontx############'),
(4,62,'jennifer#wallace#291berry,bellairetx############'),
(4,62,'ahmad#jabbar#980dallas,houstontx############'),
(4,62,'alicia#zelaya#3321castle,springtx############'),
(4,63,'john#smith#731fondren,houstontx############'),
(4,63,'franklin#wong#638voss,houstontx############'),
(4,63,'joyce#english#5631rice,houstontx############'),
(4,63,'ramesh#narayan#975fireoak,humbletx############'),
(4,63,'james#borg#450stone,houstontx############'),
(4,63,'jennifer#wallace#291berry,bellairetx############'),
(4,63,'ahmad#jabbar#980dallas,houstontx############'),
(4,63,'alicia#zelaya#3321castle,springtx############'),
(4,64,'john#smith#731fondren,houstontx############'),
(4,64,'franklin#wong#638voss,houstontx############'),
(4,64,'ramesh#narayan#975fireoak,humbletx############'),
(4,65,'joyce#english#5631rice,houstontx#1972-07-31###########'),
(4,65,'ahmad#jabbar#980dallas,houstontx#1969-03-29###########'),
(4,65,'alicia#zelaya#3321castle,springtx#1968-01-19###########'),
(4,66,'john#smith#731fondren,houstontx#1965-01-09###########'),
(4,66,'ahmad#jabbar#980dallas,houstontx#1969-03-29###########'),
(4,66,'alicia#zelaya#3321castle,springtx#1968-01-19###########'),
(4,67,'john#smith#731fondren,houstontx############'),
(4,67,'franklin#wong#638voss,houstontx############'),
(4,67,'joyce#english#5631rice,houstontx############'),
(4,67,'ramesh#narayan#975fireoak,humbletx############'),
(4,67,'james#borg#450stone,houstontx############'),
(4,67,'jennifer#wallace#291berry,bellairetx############'),
(4,67,'ahmad#jabbar#980dallas,houstontx############'),
(4,67,'alicia#zelaya#3321castle,springtx############'),
(4,68,'john#smith#731fondren,houstontx############'),
(4,68,'franklin#wong#638voss,houstontx############'),
(4,68,'joyce#english#5631rice,houstontx############'),
(4,68,'ramesh#narayan#975fireoak,humbletx############'),
(4,68,'james#borg#450stone,houstontx############'),
(4,68,'jennifer#wallace#291berry,bellairetx############'),
(4,68,'ahmad#jabbar#980dallas,houstontx############'),
(4,68,'alicia#zelaya#3321castle,springtx############'),
(4,69,'john#731fondren,houstontx#############'),
(4,69,'franklin#638voss,houstontx#############'),
(4,69,'joyce#5631rice,houstontx#############'),
(4,69,'ramesh#975fireoak,humbletx#############'),
(4,69,'james#450stone,houstontx#############'),
(4,69,'jennifer#291berry,bellairetx#############'),
(4,69,'ahmad#980dallas,houstontx#############'),
(4,69,'alicia#3321castle,springtx#############'),
(4,70,'john#smith#731fondren,houstontx############'),
(4,70,'franklin#wong#638voss,houstontx############'),
(4,70,'joyce#english#5631rice,houstontx############'),
(4,70,'ramesh#narayan#975fireoak,humbletx############'),
(4,70,'james#borg#450stone,houstontx############'),
(4,70,'jennifer#wallace#291berry,bellairetx############'),
(4,70,'ahmad#jabbar#980dallas,houstontx############'),
(4,70,'alicia#zelaya#3321castle,springtx############'),
(4,71,'john#smith#731fondren,houstontx############'),
(4,71,'franklin#wong#638voss,houstontx############'),
(4,71,'joyce#english#5631rice,houstontx############'),
(4,71,'james#borg#450stone,houstontx############'),
(4,71,'ahmad#jabbar#980dallas,houstontx############'),
(4,72,'ahmad#jabbar#980dallas,houstontx############'),
(4,73,'john#smith#731fondren,houstontx############'),
(4,73,'joyce#english#5631rice,houstontx############'),
(4,73,'james#borg#450stone,houstontx############'),
(4,73,'jennifer#wallace#291berry,bellairetx############'),
(4,74,'ramesh#narayan#975fireoak,humbletx############'),
(4,74,'alicia#zelaya#3321castle,springtx############'),
(4,75,'ramesh#narayan#975fireoak,humbletx############'),
(4,80,'john#smith#39600.000000000############'),
(4,80,'franklin#wong#40700.000000000############'),
(4,80,'joyce#english#27500.000000000############'),
(4,80,'ramesh#narayan#41800.000000000############'),
(4,81,'136000##############'),
(4,82,'25000#38000#############'),
(4,83,'8##############'),
(4,84,'3##############'),
(4,85,'3##############'),
(4,86,'4##############'),
(4,87,'8##############'),
(4,88,'5#25000#34000.0000#38000###########'),
(4,88,'1#55000#55000.0000#55000###########'),
(4,88,'4#31000#37000.0000#46000###########'),
(4,89,'1#55000#55000.0000#55000###########'),
(4,89,'4#31000#37000.0000#46000###########'),
(4,100,'5#3#############'),
(4,100,'1#1#############'),
(4,100,'4#3#############'),
(4,101,'5#3#############'),
(4,101,'4#3#############'),
(4,102,'1##############'),
(4,102,'4##############'),
(4,103,'1#1#############'),
(4,103,'4#3#############'),
(4,104,'john#smith#731fondren,houstontx############'),
(4,104,'franklin#wong#638voss,houstontx############'),
(4,105,'franklin#wong#638voss,houstontx############'),
(4,105,'ramesh#narayan#975fireoak,humbletx############'),
(4,105,'james#borg#450stone,houstontx############'),
(4,105,'jennifer#wallace#291berry,bellairetx############'),
(4,106,'123456789##############'),
(4,106,'333445555##############'),
(4,106,'666884444##############'),
(4,106,'888665555##############'),
(4,106,'987654321##############'),
(4,106,'987987987##############'),
(4,106,'999887777##############'),
(4,107,'333445555##############'),
(4,107,'888665555##############'),
(4,107,'987654321##############'),
(4,108,'123456789##############'),
(4,108,'666884444##############'),
(4,108,'987987987##############'),
(4,108,'999887777##############'),
(4,120,'john#smith#731fondren,houstontx#5#5#research#########'),
(4,120,'john#smith#731fondren,houstontx#5#1#headquarters#########'),
(4,120,'john#smith#731fondren,houstontx#5#4#administration#########'),
(4,120,'franklin#wong#638voss,houstontx#5#5#research#########'),
(4,120,'franklin#wong#638voss,houstontx#5#1#headquarters#########'),
(4,120,'franklin#wong#638voss,houstontx#5#4#administration#########'),
(4,120,'joyce#english#5631rice,houstontx#5#5#research#########'),
(4,120,'joyce#english#5631rice,houstontx#5#1#headquarters#########'),
(4,120,'joyce#english#5631rice,houstontx#5#4#administration#########'),
(4,120,'ramesh#narayan#975fireoak,humbletx#5#5#research#########'),
(4,120,'ramesh#narayan#975fireoak,humbletx#5#1#headquarters#########'),
(4,120,'ramesh#narayan#975fireoak,humbletx#5#4#administration#########'),
(4,120,'james#borg#450stone,houstontx#1#5#research#########'),
(4,120,'james#borg#450stone,houstontx#1#1#headquarters#########'),
(4,120,'james#borg#450stone,houstontx#1#4#administration#########'),
(4,120,'jennifer#wallace#291berry,bellairetx#4#5#research#########'),
(4,120,'jennifer#wallace#291berry,bellairetx#4#1#headquarters#########'),
(4,120,'jennifer#wallace#291berry,bellairetx#4#4#administration#########'),
(4,120,'ahmad#jabbar#980dallas,houstontx#4#5#research#########'),
(4,120,'ahmad#jabbar#980dallas,houstontx#4#1#headquarters#########'),
(4,120,'ahmad#jabbar#980dallas,houstontx#4#4#administration#########'),
(4,120,'alicia#zelaya#3321castle,springtx#4#5#research#########'),
(4,120,'alicia#zelaya#3321castle,springtx#4#1#headquarters#########'),
(4,120,'alicia#zelaya#3321castle,springtx#4#4#administration#########'),
(4,121,'john#smith#731fondren,houstontx#research#5##########'),
(4,121,'franklin#wong#638voss,houstontx#research#5##########'),
(4,121,'joyce#english#5631rice,houstontx#research#5##########'),
(4,121,'ramesh#narayan#975fireoak,humbletx#research#5##########'),
(4,121,'james#borg#450stone,houstontx#headquarters#1##########'),
(4,121,'jennifer#wallace#291berry,bellairetx#administration#4##########'),
(4,121,'ahmad#jabbar#980dallas,houstontx#administration#4##########'),
(4,121,'alicia#zelaya#3321castle,springtx#administration#4##########'),
(4,122,'john#smith#731fondren,houstontx#research#5##########'),
(4,122,'franklin#wong#638voss,houstontx#research#5##########'),
(4,122,'joyce#english#5631rice,houstontx#research#5##########'),
(4,122,'ramesh#narayan#975fireoak,humbletx#research#5##########'),
(4,122,'james#borg#450stone,houstontx#headquarters#1##########'),
(4,122,'jennifer#wallace#291berry,bellairetx#administration#4##########'),
(4,122,'ahmad#jabbar#980dallas,houstontx#administration#4##########'),
(4,122,'alicia#zelaya#3321castle,springtx#administration#4##########'),
(4,123,'john#smith#731fondren,houstontx#research#5##########'),
(4,123,'franklin#wong#638voss,houstontx#research#5##########'),
(4,123,'joyce#english#5631rice,houstontx#research#5##########'),
(4,123,'ramesh#narayan#975fireoak,humbletx#research#5##########'),
(4,123,'james#borg#450stone,houstontx#headquarters#1##########'),
(4,123,'jennifer#wallace#291berry,bellairetx#administration#4##########'),
(4,123,'ahmad#jabbar#980dallas,houstontx#administration#4##########'),
(4,123,'alicia#zelaya#3321castle,springtx#administration#4##########'),
(4,124,'john#smith#731fondren,houstontx#333445555#franklin#wong#########'),
(4,124,'franklin#wong#638voss,houstontx#888665555#james#borg#########'),
(4,124,'joyce#english#5631rice,houstontx#333445555#franklin#wong#########'),
(4,124,'ramesh#narayan#975fireoak,humbletx#333445555#franklin#wong#########'),
(4,124,'james#borg#450stone,houstontx############'),
(4,124,'jennifer#wallace#291berry,bellairetx#888665555#james#borg#########'),
(4,124,'ahmad#jabbar#980dallas,houstontx#987654321#jennifer#wallace#########'),
(4,124,'alicia#zelaya#3321castle,springtx#987654321#jennifer#wallace#########'),
(4,125,'alice#1988-12-30#john#smith###########'),
(4,125,'elizabeth#1967-05-05#john#smith###########'),
(4,125,'michael#1988-01-04#john#smith###########'),
(4,125,'alice#1986-04-04#franklin#wong###########'),
(4,125,'joy#1958-05-03#franklin#wong###########'),
(4,125,'theodore#1983-10-25#franklin#wong###########'),
(4,125,'##joyce#english###########'),
(4,125,'##ramesh#narayan###########'),
(4,125,'##james#borg###########'),
(4,125,'abner#1942-02-28#jennifer#wallace###########'),
(4,125,'##ahmad#jabbar###########'),
(4,125,'##alicia#zelaya###########'),
(4,126,'james#borg#headquarters#1###########'),
(4,126,'jennifer#wallace#administration#4###########'),
(4,126,'franklin#wong#research#5###########'),
(4,127,'john#smith#5############'),
(4,127,'franklin#wong#5#research###########'),
(4,127,'joyce#english#5############'),
(4,127,'ramesh#narayan#5############'),
(4,127,'james#borg#1#headquarters###########'),
(4,127,'jennifer#wallace#4#administration###########'),
(4,127,'ahmad#jabbar#4############'),
(4,127,'alicia#zelaya#4############'),
(4,128,'john#smith#731fondren,houstontx#reorganization#houston##########'),
(4,128,'john#smith#731fondren,houstontx#productz#houston##########'),
(4,128,'franklin#wong#638voss,houstontx#reorganization#houston##########'),
(4,128,'franklin#wong#638voss,houstontx#productz#houston##########'),
(4,128,'joyce#english#5631rice,houstontx#reorganization#houston##########'),
(4,128,'joyce#english#5631rice,houstontx#productz#houston##########'),
(4,128,'james#borg#450stone,houstontx#reorganization#houston##########'),
(4,128,'james#borg#450stone,houstontx#productz#houston##########'),
(4,128,'jennifer#wallace#291berry,bellairetx#productx#bellaire##########'),
(4,128,'ahmad#jabbar#980dallas,houstontx#reorganization#houston##########'),
(4,128,'ahmad#jabbar#980dallas,houstontx#productz#houston##########'),
(4,129,'james#borg#1937-11-10#franklin#wong#1955-12-08#########'),
(4,129,'james#borg#1937-11-10#jennifer#wallace#1941-06-20#########'),
(4,129,'jennifer#wallace#1941-06-20#franklin#wong#1955-12-08#########');

-- -------------------------------------------------
-- autograding system
-- -------------------------------------------------
-- The magic44_data_capture table is used to store the data created by the student's queries
-- The table is populated by the magic44_evaluate_queries stored procedure
-- The data in the table is used to populate the magic44_test_results table for analysis

drop table if exists magic44_data_capture;
create table magic44_data_capture (
	stateID integer, queryID integer,
    columnDump0 varchar(1000), columnDump1 varchar(1000), columnDump2 varchar(1000), columnDump3 varchar(1000), columnDump4 varchar(1000),
    columnDump5 varchar(1000), columnDump6 varchar(1000), columnDump7 varchar(1000), columnDump8 varchar(1000), columnDump9 varchar(1000),
	columnDump10 varchar(1000), columnDump11 varchar(1000), columnDump12 varchar(1000), columnDump13 varchar(1000), columnDump14 varchar(1000)
);

-- The magic44_column_listing table is used to help prepare the insert statements for the magic44_data_capture
-- table for the student's queries which may have variable numbers of columns (the table is prepopulated)

drop table if exists magic44_column_listing;
create table magic44_column_listing (
	columnPosition integer,
    simpleColumnName varchar(50),
    nullColumnName varchar(50)
);

insert into magic44_column_listing (columnPosition, simpleColumnName) values
(0, 'columnDump0'), (1, 'columnDump1'), (2, 'columnDump2'), (3, 'columnDump3'), (4, 'columnDump4'),
(5, 'columnDump5'), (6, 'columnDump6'), (7, 'columnDump7'), (8, 'columnDump8'), (9, 'columnDump9'),
(10, 'columnDump10'), (11, 'columnDump11'), (12, 'columnDump12'), (13, 'columnDump13'), (14, 'columnDump14');

drop function if exists magic44_gen_simple_template;
delimiter //
create function magic44_gen_simple_template(numberOfColumns integer)
	returns varchar(1000) deterministic
begin
return (select group_concat(simpleColumnName separator ', ') from magic44_column_listing
	where columnPosition < numberOfColumns);
end //
delimiter ;

drop function if exists magic44_query_exists;
delimiter //
create function magic44_query_exists(thisQuery integer)
	returns integer deterministic
begin
	return (select exists (select * from information_schema.views
		where table_schema = @thisDatabase
        and table_name like concat('practiceQuery', thisQuery)));
end //
delimiter ;

-- Exception checking has been implemented to prevent (as much as reasonably possible) errors
-- in the queries being evaluated from interrupting the testing process
-- The magic44_log_query_errors table capture these errors for later review

drop table if exists magic44_log_query_errors;
create table magic44_log_query_errors (
	state_id integer,
    query_id integer,
    error_code char(5),
    error_message text	
);

drop function if exists magic44_query_capture;
delimiter //
create function magic44_query_capture(thisQuery integer, thisState integer)
	returns varchar(1000) reads sql data
begin
	set @numberOfColumns = (select count(*) from information_schema.columns
		where table_schema = @thisDatabase
        and table_name = concat('practiceQuery', thisQuery));

	set @buildQuery = 'insert into magic44_data_capture (stateID, queryID, ';
    set @buildQuery = concat(@buildQuery, magic44_gen_simple_template(@numberOfColumns));
    set @buildQuery = concat(@buildQuery, ') select ');
    set @buildQuery = concat(@buildQuery, thisState, ', ');
    set @buildQuery = concat(@buildQuery, thisQuery, ', practiceQuery');
    set @buildQuery = concat(@buildQuery, thisQuery, '.* from practiceQuery');
    set @buildQuery = concat(@buildQuery, thisQuery, ';');
    
return @buildQuery;
end //
delimiter ;

-- This null result set marker is used to avoid some edge cases (e.g., empty
-- test cases) when capturing the results.  This value is also used when
-- analyzing the submitted queries.
set @null_result_set_marker = 'result#set#exists############';
drop procedure if exists magic44_evaluate_query;
delimiter //
create procedure magic44_evaluate_query(in thisQuery integer, in thisState integer)
begin
	declare err_code char(5) default '00000';
    declare err_msg text;
    
	declare continue handler for SQLEXCEPTION
    begin
		get diagnostics condition 1
			err_code = RETURNED_SQLSTATE, err_msg = MESSAGE_TEXT;
	end;

	if magic44_query_exists(thisQuery) then
		-- data capture tombstone added to alleviate empty result set anomalies
		insert into magic44_test_results values (thisState, thisQuery, @null_result_set_marker);
        
		-- prepare and evaluate query contents
		set @sql_text = magic44_query_capture(thisQuery, thisState);
		prepare statement from @sql_text;
        execute statement;
        if err_code <> '00000' then
			insert into magic44_log_query_errors values (thisState, thisQuery, err_code, err_msg);
		end if;
        deallocate prepare statement;
	end if;
end //
delimiter ;

drop procedure if exists magic44_evaluate_solutions;
delimiter //
create procedure magic44_evaluate_solutions()
sp_main: begin
	-- ensure that the state and query target tables exist
	if not exists (select * from magic44_state_holds_rows) then leave sp_main; end if;
	if not exists (select * from magic44_expected_results) then leave sp_main; end if;
    
	set @startingState = (select min(state_id) from magic44_state_holds_rows); 
	set @endingState = (select max(state_id) from magic44_state_holds_rows); 
	set @startingQuery = (select min(query_id) from magic44_expected_results); 
	set @endingQuery = (select max(query_id) from magic44_expected_results); 

    -- check all queries for each database state
    set @stateCounter = @startingState;
    check_next_state: while (@stateCounter <= @endingState) do
		if @stateCounter not in (select state_id from magic44_state_holds_rows) then
			set @stateCounter = @stateCounter + 1;
			iterate check_next_state;
		end if;
        call magic44_set_database_state(@stateCounter);
        
		set @queryCounter = @startingQuery;
        check_next_query: while (@queryCounter <= @endingQuery) do
			if not magic44_query_exists(@queryCounter) then
				set @queryCounter = @queryCounter + 1;
				iterate check_next_query;
			end if;
        
			call magic44_evaluate_query(@queryCounter, @stateCounter);
			set @queryCounter = @queryCounter + 1;
		end while;
        
		set @stateCounter = @stateCounter + 1;
	end while;
end //
delimiter ;

-- -------------------------------------------------
-- evaluate all queries against the different states
-- -------------------------------------------------

call magic44_evaluate_solutions();
-- Added [Wed, 7 Sep 2022] to return the database to its original state after testing
call magic44_set_database_state(0);

insert into magic44_test_results
select stateID, queryID, concat_ws('#', ifnull(columndump0, ''), ifnull(columndump1, ''), ifnull(columndump2, ''), ifnull(columndump3, ''),
ifnull(columndump4, ''), ifnull(columndump5, ''), ifnull(columndump6, ''), ifnull(columndump7, ''), ifnull(columndump8, ''), ifnull(columndump9, ''),
ifnull(columndump10, ''), ifnull(columndump11, ''), ifnull(columndump12, ''), ifnull(columndump13, ''), ifnull(columndump14, ''))
from magic44_data_capture;

-- Delete the unneeded rows from the answers table to simplify later analysis
delete from magic44_expected_results where not magic44_query_exists(query_id);

-- Modify the row hash results for the results table to eliminate spaces and convert all characters to lowercase
update magic44_test_results set row_hash = lower(replace(row_hash, ' ', ''));

/*
The magic44_content_differences view displays the differences between the answers and test results in terms of the
row attributes and values.  The error_category column contains missing for rows that are not included in the test
results but should be, while extra represents the rows that should not be included in the test results.  The row_hash
column contains the values of the row in a single string with the attribute values separated by a selected delimeter
(i.e., the pound sign/#).
*/

create or replace view magic44_scoring_content_differences as
select query_id, state_id, 'missing' as category, row_hash
from magic44_expected_results where row(state_id, query_id, row_hash) not in
	(select state_id, query_id, row_hash from magic44_test_results)
union
select query_id, state_id, 'extra' as category, row_hash
from magic44_test_results where row(state_id, query_id, row_hash) not in
	(select state_id, query_id, row_hash from magic44_expected_results)
order by query_id, state_id, row_hash;

drop table if exists magic44_autograding_content_errors;
create table magic44_autograding_content_errors (
	query_id integer,
    state_id integer,
    extra_or_missing char(20),
    row_hash varchar(15000)
);

insert into magic44_autograding_content_errors
select * from magic44_scoring_content_differences order by query_id, state_id, row_hash;

create or replace view magic44_tally_row_count as
select * from (select state_id, query_id, count(*) - 1 as actual_row_count from magic44_test_results
	group by state_id, query_id) as actual_dump
natural join
(select state_id, query_id, count(*) - 1 as expected_row_count from magic44_expected_results
	group by state_id, query_id) as expected_dump;

drop function if exists magic44_valid_row;
delimiter //
create function magic44_valid_row(ip_row_hash varchar(15000))
	returns boolean reads sql data
begin
	return (ip_row_hash <> @null_result_set_marker);
end //
delimiter ;

create or replace view magic44_tally_correct as
select state_id, query_id, count(*) as match_total
from magic44_test_results where row(state_id, query_id, row_hash)
	in (select state_id, query_id, row_hash from magic44_expected_results)
    and magic44_valid_row(row_hash) group by state_id, query_id;

create or replace view magic44_tally_missing as
select state_id, query_id, count(*) as missing_total
from magic44_expected_results where row(state_id, query_id, row_hash)
    not in (select state_id, query_id, row_hash from magic44_test_results)
    and magic44_valid_row(row_hash) group by state_id, query_id;

create or replace view magic44_tally_excess as
select state_id, query_id, count(*) as excess_total
from magic44_test_results where row(state_id, query_id, row_hash)
    not in (select state_id, query_id, row_hash from magic44_expected_results)
    and magic44_valid_row(row_hash) group by state_id, query_id;

-- Updated [Wed, 23 Aug 2022] to identify duplicate rows testing (edge) case
drop function if exists magic44_category_logic;
delimiter //
create function magic44_category_logic(actual integer, expected integer, matching integer,
	missing integer, excess integer) returns varchar(50) deterministic
begin
	if (actual = expected and expected = matching) then return 'all_correct';
    elseif (actual <> expected and excess = 0) then return 'likely_duplicate_rows';
	elseif (actual = expected) then return 'columns_values_incorrect';
	elseif (missing > 0 and excess > 0) then return 'missing_and_excess_rows';
	elseif (missing > 0) then return 'missing_rows';
	elseif (excess > 0) then return 'excess_rows';
	else return 'undefined_status';
    end if;
end //
delimiter ;

drop function if exists magic44_scoring_logic;
delimiter //
create function magic44_scoring_logic(actual integer, expected integer, matching integer,
	missing integer, excess integer) returns decimal(5, 2) deterministic
begin
	set @line_score = 0.00;
	if (actual = expected and expected = matching and missing = 0 and excess = 0) then
		set @line_score = @line_score + 1.00; end if;
    return @line_score + least(1.00, round((matching + 1.00) / (expected + 1.00), 2));
end //
delimiter ;

create or replace view magic44_scoring_details as
select query_id, state_id, actual_row_count, expected_row_count, ifnull(match_total, 0) as match_count,
	ifnull(missing_total, 0) as missing_count, ifnull(excess_total, 0) as excess_count,
    magic44_category_logic(actual_row_count, expected_row_count, ifnull(match_total, 0),
		ifnull(missing_total, 0), ifnull(excess_total, 0)) as category,
    magic44_scoring_logic(actual_row_count, expected_row_count, ifnull(match_total, 0),
		ifnull(missing_total, 0), ifnull(excess_total, 0)) as score
from ((magic44_tally_row_count natural left outer join magic44_tally_correct)
    natural left outer join magic44_tally_missing) natural left outer join magic44_tally_excess
order by query_id, state_id, category;

drop table if exists magic44_autograding_scoring_details;
create table magic44_autograding_scoring_details (
	query_id integer,
    state_id integer,
    actual_row_count integer,
    expected_row_count integer,
    match_total integer,
	missing_total integer,
    excess_total integer,
    category varchar(50),
    score decimal(5, 2)
);

insert into magic44_autograding_scoring_details
select * from magic44_scoring_details order by query_id, state_id, category;

create or replace view magic44_scoring_summary as
(select query_id, category, group_concat(state_id) as states_affected,
	sum(score) as score_subtotals from magic44_scoring_details
	group by query_id, category
union
select null, '{overall_score}', null, sum(score) from magic44_scoring_details);

drop table if exists magic44_autograding_scoring_summary;
create table magic44_autograding_scoring_summary (
	query_id integer,
    category varchar(50),
    state_listing varchar(50),
    score decimal(5, 2)
);

insert into magic44_autograding_scoring_summary
select * from magic44_scoring_summary;

-- Remove all unneeded tables, views, stored procedures and functions.
-- Keep only those structures needed to provide student feedback.
drop view if exists magic44_scoring_content_differences;
drop view if exists magic44_scoring_details;
drop view if exists magic44_scoring_summary;
drop view if exists magic44_tally_correct;
drop view if exists magic44_tally_excess;
drop view if exists magic44_tally_missing;
drop view if exists magic44_tally_row_count;
drop procedure if exists magic44_evaluate_query;
drop procedure if exists magic44_evaluate_solutions;
drop function if exists magic44_category_logic;
drop function if exists magic44_gen_simple_template;
drop function if exists magic44_query_capture;
drop function if exists magic44_query_exists;
drop function if exists magic44_scoring_logic;
drop function if exists magic44_valid_row;
drop table if exists magic44_column_listing;
drop table if exists magic44_data_capture;
