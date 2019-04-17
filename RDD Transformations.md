## Common Transformation

###  map(func)

The most fundamental, versatile, and commonly used transformation is the map operation. It is used to transform some aspect of the data per row to something else.

Using a Map Transformation  to Convert all characters in the string to uppercase:

```scala
val allCapsRDD =  stringRDD.map(line => line.toUpperCase)
allCapsRDD.collect().foreach(println)
```



### flatMap(func)

### filter(func)

### mapPartitions(func)/mapPartitionsWithIndex(index,func)



