from pyspark import SparkConf, SparkContext

conf = SparkConf().setMaster("spark://spark-master:7077").setAppName("WordCount")
sc = SparkContext(conf = conf)

input = sc.textFile("file:///data/document/book.txt")
words = input.flatMap(lambda x: x.split())
wordCounts = words.countByValue()

for word, count in wordCounts.items():
    cleanWord = word.encode('ascii', 'ignore')
    if (cleanWord):
        print(cleanWord.decode() + " " + str(count))
