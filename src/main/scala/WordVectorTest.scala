import org.apache.spark.sql.SparkSession
import org.apache.spark.sql._
import org.apache.spark.sql.functions._

import java.net.URI

import org.apache.spark.ml.feature.Word2Vec

import org.apache.hadoop.fs.FileSystem
import org.apache.hadoop.fs.FileUtil
import org.apache.hadoop.fs.Path

/**
 * Spark analytics
 * https://spark.apache.org/docs/2.4.0/mllib-feature-extraction.html#word2vec
 * 
 */
object WordVectorTest {
  def main(args: Array[String]) {
    if (args.length != 1) {
	    println("Usage: WordVectorTest <input file>")
	    sys.exit(1)
	  }

    // Create the the Spark session
    val spark = SparkSession
      .builder()
      .appName("Word Vector Test")
      .config("spark.sql.crossJoin.enabled", true)
      .getOrCreate()
    import spark.implicits._

    // Open the training file and read line by line
    val trainingDF = spark.read
      .option("header", true)
      .text(args(0))
      .as[(String)]
      .map(line  => line.trim().split("\\s+").toSeq)

    // Create the word vector object.
    val word2vec = new Word2Vec()
      .setInputCol("value")
      .setOutputCol("result")

    // Create the model
    val model = word2vec.fit(trainingDF)
    model.save("model")

    /*
          .coalesce(1)
          .write
            .format("csv")
            .option("header", true)
            .save("out/submissions-byweekdayhour")
        copyMerge(spark, "out/submissions-byweekdayhour", "out/submissions-byweekdayhour.csv")
        */
  }
  

  /**
   * Copy and merge all of the output data into one file
   * This isn't working properly. It gets data in the right order, but then copies the header from each file.
   */
  private def copyMerge(spark: SparkSession, srcPath: String, dstPath: String) = {
    val srcFileSystem = FileSystem.get(new URI(srcPath), spark.sparkContext.hadoopConfiguration)
    val dstFileSystem = FileSystem.get(new URI(dstPath), spark.sparkContext.hadoopConfiguration)
    dstFileSystem.delete(new Path(dstPath), true)
    FileUtil.copyMerge(srcFileSystem,  new Path(srcPath), dstFileSystem,  new Path(dstPath), true, spark.sparkContext.hadoopConfiguration, null)
  }
}
