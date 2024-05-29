FROM python:3.10-alpine

WORKDIR /
COPY server.py .

# Update pip to use latest version
RUN pip3 install --upgrade pip

RUN pip install flask requests

CMD ["python", "server.py"]
