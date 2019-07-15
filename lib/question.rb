# encoding: utf-8

# Подключаем парсер.
require 'rexml/document'

# Класс Вопрос.
class Question
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

      # Для каждого вопроса собираем время, текст вопроса и варианты ответов.
      questions_element.elements.each do |question_element|
        # Время на вопрос передаём с ключом time.
        question['time'] = question_element.attributes['time']
        case question_element.name
        when 'text'
          # Складываем в массив текст вопроса с ключом text.
          question['text'] = question_element.text
        when 'answers'
          question_element.elements.each_with_index do |answer, index|
            if answer.attributes['right']
              # Сохраняем с ключом true_answer правильный ответ.
              question['right_answer'] = answer.text
            else
              # Остальные варианты ответов складываем с ключами false_answer.
              question["false_answer_#{index}"] = answer.text
            end
          end
        end
      end
      # добавляем свежесозданый вопрос в массив
      questions << Question.new(question)
    end

    # возвращаем массив вопросов из метода
    questions
  end

  def initialize(question)
    @text = question['text']
    @time = question['time']
    @answer_answers = question.values_at('question')
  end

# Задаем вопрос, используя массив вариантов ответа
  def ask
    @answer_answers.each_with_index do |answer, index|
      puts "#{index + 1}. #{answer}"
    end

    user_index = STDIN.gets.chomp.to_i - 1
    @correct = (@right_answer_index == user_index)
  end

  # Возвращает true если на вопрос был дан верный ответ
  def correctly_answered?
    @correct
  end

  # Выводит текст вопроса
  def show
    puts
    puts @text
  end
end
