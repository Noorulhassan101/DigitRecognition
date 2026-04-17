import tensorflow as tf

def convert():
    print("Loading model.h5...")
    model = tf.keras.models.load_model('model.h5')
    print("Converting to TFLite...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()
    
    with open('model.tflite', 'wb') as f:
        f.write(tflite_model)
    print("Saved to model.tflite!")

if __name__ == "__main__":
    convert()
