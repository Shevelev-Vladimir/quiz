# encoding: utf-8

# Программа "Мини-викторина".
# Вывод версии программы.
VERSION = 2.0
puts  "Программа \"Мини-викторина\". Версия #{VERSION}."

# Этот код необходим только при использовании русских букв на Windows
if Gem.win_platform?
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

# Подключаем парсер.
require_relative "lib/question"

# Получаем путь к папке data.
parh_data = "#{__dir__}/data"
# Составляем путь к файлу с вопросами.
file_name = parh_data + "/questions.xml"

begin
  questions = Question.read_questions_from_xml(file_name)

  # Счетчик правильных ответов.
  right_answers_counter = 0

  questions.each do |question|
    question.show
    question.ask
    message = 
      if question.time_over?
        'Вы не успели.'
      elsif question.correctly_answered? 
        right_answers_counter += 1
        'Верно'
      else
        "Неверно. Правильный ответ: #{question.right_answer}."
      end
    puts message
  end

  puts "\nУ Вас #{right_answers_counter} правильных " \
    "ответов из #{questions.size}."

rescue Errno::ENOENT => e
  puts "\nФайл не найден. #{e.message}"
rescue REXML::ParseException => e
  puts "Похоже, файл #{file_name} испорчен: \n#{e.message}"
rescue  Interrupt
  puts "\nВы завершили программу."
end
