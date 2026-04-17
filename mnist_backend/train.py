import os
import json
import numpy as np
import tensorflow as tf
from tensorflow.keras import layers, models
from sklearn.metrics import confusion_matrix

def train_model():
    print("Loading MNIST dataset...")
    (x_train, y_train), (x_test, y_test) = tf.keras.datasets.mnist.load_data()
    
    # Normalize and reshape to (28, 28, 1)
    x_train = x_train.astype('float32') / 255.0
    x_test = x_test.astype('float32') / 255.0
    x_train = np.expand_dims(x_train, -1)
    x_test = np.expand_dims(x_test, -1)
    
    print("Building CNN model...")
    model = models.Sequential([
        layers.Conv2D(32, (3, 3), activation='relu', input_shape=(28, 28, 1)),
        layers.MaxPooling2D((2, 2)),
        layers.Conv2D(64, (3, 3), activation='relu'),
        layers.MaxPooling2D((2, 2)),
        layers.Flatten(),
        layers.Dense(128, activation='relu'),
        layers.Dropout(0.5),
        layers.Dense(10, activation='softmax')
    ])
    
    model.compile(optimizer='adam',
                  loss='sparse_categorical_crossentropy',
                  metrics=['accuracy'])
    
    # Train for 10 epochs
    history = model.fit(x_train, y_train, epochs=10, 
                        validation_data=(x_test, y_test),
                        batch_size=128)
                        
    # Generate predictions for confusion matrix
    print("Generating predictions for confusion matrix...")
    predictions = model.predict(x_test)
    y_pred = np.argmax(predictions, axis=1)
    cm = confusion_matrix(y_test, y_pred)
    cm_list = cm.tolist()
    
    # Save the metrics to use in the frontend
    metrics_data = {
        "accuracy": history.history['accuracy'],
        "val_accuracy": history.history['val_accuracy'],
        "loss": history.history['loss'],
        "val_loss": history.history['val_loss'],
        "confusion_matrix": cm_list
    }
    
    base_path = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(base_path, 'metrics.json'), 'w') as f:
        json.dump(metrics_data, f)
    
    model_path = os.path.join(base_path, 'model.h5')
    print(f"Saving model to {model_path}...")
    model.save(model_path)
    print("Training Complete!")

if __name__ == "__main__":
    train_model()
