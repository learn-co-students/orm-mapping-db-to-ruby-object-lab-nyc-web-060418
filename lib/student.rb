require 'pry'

class Student
  attr_accessor :id, :name, :grade

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    student = self.new
    student.id = row[0]
    student.name = row[1]
    student.grade = row[2]
    student
  end

  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    sql = <<-SQL_HEREDOC
    select * from students

    SQL_HEREDOC
    array = []
    DB[:conn].execute(sql).each do |student|
      array << self.new_from_db(student)
    end

    array
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL_HEREDOC
    select * from students where name = ? limit 1
    SQL_HEREDOC

    student = DB[:conn].execute(sql, name)[0]
    self.new_from_db(student)
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
  end

  def self.count_all_students_in_grade_9
    sql = <<-SQL
      select * from students where grade = 9
    SQL

    students = DB[:conn].execute(sql)
    students
  end

  def self.students_below_12th_grade
    filtered_array = self.all.select do |student|
      student.grade.to_i < 12
    end
  end

  def self.first_X_students_in_grade_10(number)
    filtered_array = []
    DB[:conn].execute("select * from students where grade = 10 limit ?", number).each do |student|
      filtered_array << student
    end
    filtered_array
  end

  def self.first_student_in_grade_10
    student = self.all.find do |student|
      student.grade.to_i == 10
    end
    student
  end

  def self.all_students_in_grade_X(number)
    students = self.all.select do |student|
      student.grade.to_i == number
    end
    students
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
end
