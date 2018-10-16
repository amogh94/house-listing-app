# README

All the unknown commits to this project are realated to - rvijaya4@ncsu.edu (if required relevant commit details can be provided)

This application will be deployed on Heroku...currently having issues connecting to github.ncsu, the heroku is always connecting to the local github account. Once the application deployment is done, we will post the link here.

Update: Deployment at:
https://quiet-anchorage-16656.herokuapp.com

The project has been completed as per requirements with complete user experience, filter search and request validations. No code changes will be made after the deadline. Only the Heroku deployment will be updated.

Create table queries:

create table companies(
     id INT PRIMARY KEY AUTO_INCREMENT,
     name VARCHAR(100) NOT NULL,
     website VARCHAR(320),
     address VARCHAR(1000),
     size VARCHAR(25),
     founded YEAR,
     revenue DECIMAL,
     synopsis MEDIUMTEXT
     );


create table users(
     id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
     name VARCHAR(100),
     email VARCHAR(320) NOT NULL,
     password_digest VARCHAR(200),
     role INT NOT NULL,
     phone VARCHAR(20),
     preferred_contact_method VARCHAR(10),
     company_id INT,
     FOREIGN KEY(company_id) REFERENCES companies(id)
     );



create table houses(
     id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
     company_id INT,
     location VARCHAR(1000),
     sq_footage VARCHAR(100),
     year_build YEAR,
     style VARCHAR(20),
     list_price DECIMAL,
     floors INT,
     basement TINYINT(1),
     current_owner VARCHAR(100),
     realtor_id INT,
     FOREIGN KEY(company_Id) REFERENCES companies(id),
     FOREIGN KEY(realtor_id) REFERENCES users(id)
     );




create table inquiries(
     id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
     user_id INT,
     subject MEDIUMTEXT,
     message MEDIUMTEXT,
     FOREIGN KEY(user_id) REFERENCES users(id)
     );


This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
