# Use an official Python runtime as a parent image
FROM python:3.12

# Set the working directory in the container
WORKDIR /app

# Install Git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone the repository
RUN git clone https://github.com/gurkanakdeniz/example-flask-crud.git .

# Set up virtual environment
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -r requirements.txt

# Set environment variables
ENV FLASK_APP=crudapp.py

# Initialize and migrate the database
RUN . venv/bin/activate && \
    flask db init && \
    flask db migrate -m "entries table" && \
    flask db upgrade

# Expose port 5000
EXPOSE 5000

# Define the command to run the application
CMD ["/bin/sh", "-c", ". venv/bin/activate && flask run --host=0.0.0.0 --port=80"]