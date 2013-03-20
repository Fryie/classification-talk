require 'csv'
require 'classifier'

# read in data
data = []
header = true

CSV.foreach('rails.csv') do |row| 
  if header
    header = false
  else
    data << {topic:row[4], text:row[3] }
  end
end

grouped = data.group_by { |datapoint| datapoint[:topic] }

randomized = data.shuffle
train = randomized[0..139]
test = randomized[140..-1]

# print statistics
puts
puts "Read in data. The following categories were found, with the respective counts"
grouped.keys.each { |key| puts "#{key}: #{grouped[key].size}" }
puts

# train
classifier = Classifier::Bayes.new(*grouped.keys)
train.each { |datapoint| classifier.train(datapoint[:topic], datapoint[:text]) }

# evaluate on test set
correct = test.inject(0) do |sum, datapoint|
  #puts "#{datapoint[:text]} -- predicted: #{classifier.classify(datapoint[:text])} -- actual: #{datapoint[:topic]}" 
  classifier.classify(datapoint[:text]).downcase==datapoint[:topic] ? sum+1 : sum
end
all = test.size

puts "#{correct}/#{all} = #{((correct.to_f/all)*100).floor} %"
