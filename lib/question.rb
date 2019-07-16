# encoding: utf-8

# Подключаем парсер.
require 'rexml/document'

# Класс Вопрос.
class Question
  attr_reader :right_answer

  def self.read_questions_from_xml(file_name)
    # Открываем файл.
    file = File.new(file_name, 'r:utf-8')

    # Создаем новый документ REXML, построенный из открытого XML файла.
    doc = REXML::Document.new(file)
    file.close

    # Создаём пустой массив содержащий объекты класса Question.
    questions = []

    doc.elements.each('questions/question') do |questions_element|
      # Ассоциативный массив содержащий элементы вопроса.
      question = {}
      # Время на вопрос передаём с ключом time.
      question['time'] = questions_element.attributes['time']
     
      # Объявляем что в хэше содержится массив, для хранения вариантов ответов.
      question['answers'] = []

      # Для каждого вопроса собираем время, текст вопроса и варианты ответов.
      questions_element.elements.each do |question_element|
        case question_element.name
        when 'text'
          # Складываем в массив текст вопроса с ключом text.
          question['text'] = question_element.text
        when 'answers'
          question_element.elements.each do |answer|
            # Складываем в массив вариант ответа.
            question['answers'] << answer.text
            question['right_answer'] = answer.text if answer.attributes['right']
          end
        end
      end
      
      # Добавляем свежесозданый вопрос в массив.
      questions << Question.new(question)
    end

    # Возвращаем массив вопросов из метода.
    questions
  end

  # Конструктор класса, принимающий на вход асс.массив.
  def initialize(params)
    @text = params['text']
    @time = params['time'].to_i
    @answer_variants = params['answers'].shuffle # Для хранения перемешенных вариантов ответа.
    @right_answer = params['right_answer'] # Для хранения правильного ответа.
  end

# Задаем вопрос, используя массив вариантов ответа
  def ask
    # Цикл для проверки ввода пользователя.
    loop do
      @answer_variants.each_with_index do |answer, index|
        puts "#{index + 1}. #{answer}"
      end

      user_index = STDIN.gets.chomp.to_i - 1
      @correct = (@right_answer == @answer_variants[user_index])
      # Выход из цикла, если ввод пользователя входит в установленные рамки.
      break if (0...@answer_variants.size).include?(user_index)
    end
  end
 
  # Возвращает true если на вопрос был дан верный ответ.
  def correctly_answered?
    @correct
  end

  # Время закончилось?
  def time_over?
    Time.now > @end_time
  end

  # Выводит текст вопроса.
  def show
    puts "\nУ Вас #{@time} секунд для ввода ответа.\n\n#{@text}"
    @end_time = Time.now + @time
  end
end
