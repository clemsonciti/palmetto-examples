import tensorflow as tf
import os

# Define a log directory in your scratch or home folder
username = os.getenv("USER")
log_dir = f"/scratch/{username}/tensorboard_logs"
os.makedirs(log_dir, exist_ok=True)

# Create some data to log
x = tf.Variable(3.0)
optimizer = tf.optimizers.SGD(learning_rate=0.01)

# Using tf.summary to log scalar values
summary_writer = tf.summary.create_file_writer(log_dir)

for step in range(100):
    with tf.GradientTape() as tape:
        loss = x * x

    grads = tape.gradient(loss, [x])
    optimizer.apply_gradients(zip(grads, [x]))

    # Write the scalar values to TensorBoard logs
    with summary_writer.as_default():
        tf.summary.scalar('loss', loss, step=step)

print(f"Logs saved in {log_dir}")
