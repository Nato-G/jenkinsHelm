FROM python:3.7-alpine

WORKDIR /app

COPY requirements.txt .

RUN apk add --no-cache gcc musl-dev linux-headers && \
    python -m venv /venv && \
    /venv/bin/pip install --no-cache-dir --upgrade pip && \
    /venv/bin/pip install --no-cache-dir -r requirements.txt

COPY . /app

ENV PYTHONPATH "${PYTHONPATH}:/app/microservice"

EXPOSE 8080

CMD ["/venv/bin/python", "microservice/main.py"]

