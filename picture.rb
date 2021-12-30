require 'pg'
require 'csv'
require 'pry'
class Main
  def self.start
    begin
      db = Db.new
      db.prepare_data
      db.choice
    rescue PG::Error => e
      puts e.message
    ensure
      $con.close if $con
    end
  end
end

class Db
  def initialize
    @con = PG.connect :dbname => 'pictures', :user => 'postgres',
                      :password => 'guletskaya13'
  end

  def prepare_data
    begin
      data=CSV.parse(File.open("/home/liza/RubymineProjects/picture/user.csv"), headers:false)
      @con.exec 'DROP TABLE IF EXISTS Users CASCADE'
      @con.exec 'CREATE TABLE Users(id SERIAL PRIMARY KEY, name VARCHAR(20), mail VARCHAR(40))'
      @con.exec "INSERT INTO Users VALUES (DEFAULT, '#{data[0][1]}', '#{data[0][2]}')"
      @con.exec "INSERT INTO Users VALUES (DEFAULT, '#{data[1][1]}', '#{data[1][2]}')"
      @con.exec "INSERT INTO Users VALUES (DEFAULT, '#{data[2][1]}', '#{data[2][2]}')"
    rescue Errno::ENOENT
      p "User file isn't found"
    end
    begin
      data=CSV.parse(File.open('/home/liza/RubymineProjects/picture/pics.csv'),headers:false)
      @con.exec 'DROP TABLE IF EXISTS Pictures'
      @con.exec "CREATE TABLE Pictures(idP SERIAL PRIMARY KEY, nameP VARCHAR(200), id INTEGER NOT NULL REFERENCES Users (id))"
      @con.exec "INSERT INTO Pictures VALUES (DEFAULT, '#{data[0][1]}', #{data[0][2]})"
      @con.exec "INSERT INTO Pictures VALUES (DEFAULT, '#{data[1][1]}', #{data[1][2]})"
      @con.exec "INSERT INTO Pictures VALUES (DEFAULT, '#{data[2][1]}', #{data[2][2]})"
      @con.exec "INSERT INTO Pictures VALUES (DEFAULT, '#{data[3][1]}', #{data[3][2]})"
      @con.exec "INSERT INTO Pictures VALUES (DEFAULT, '#{data[4][1]}', #{data[4][2]})"
      @con.exec "INSERT INTO Pictures VALUES (DEFAULT, '#{data[5][1]}', #{data[5][2]})"
    rescue Errno::ENOENT
      p "Picture file isn't found"
    end
  end

  def choice
    while true
      puts "What do you wanna do?
      1 - See which pictures has each user\n
      2 - See which pictures has a certain user\n
      3 - See which users have a certain picture\n
      4 - Add a new picture\n
      5 - Add a new user\n
      6 - Delete a picture\n
      7 - Delete a user\n
      8 - Exit"
      choice=gets.chomp
      case choice.to_i
        when 1
          @con.exec "SELECT Users.name, Pictures.nameP FROM Users NATURAL JOIN Pictures"
        when 2
          puts "Enter a name: "
          name=gets.chomp
          @con.exec "SELECT pc.nameP FROM Pictures as pc WHERE Id=(SELECT Users.id FROM Users WHERE Users.name='#{name}')"
        when 3
          puts "Enter a URL: "
          picture=gets.chomp
          @con.exec "SELECT Users.name WHERE id=(SELECT Picture.id FROM Picture WHERE Picture.name='#{picture}')"
        when 4
          puts "Enter a URL: "
          picture=gets.chomp
          @con.exec "INSERT INTO Pictures VALUES (DEFAULT, '#{picture}')"
        when 5
          puts "Enter a name and e-mail address: "
          name=gets.chomp
          mail=gets.chomp
          @con.exec "INSERT INTO Users VALUES (DEFAULT, '#{name}', '#{mail}')"
        when 6
          puts "Enter a URL: "
          picture=gets.chomp
          @con.exec "DELETE FROM Pictures WHERE nameP='#{picture}'"
        when 7
          puts "Enter a name: "
          name=gets.chomp
          @con.exec "DELETE FROM Users WHERE name='#{name})'"
        when 8
          return false
      end
    end
  end
end

Main.start

