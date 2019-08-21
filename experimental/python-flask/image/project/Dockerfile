FROM python:3.7

RUN pip install --user pipenv
ENV PATH=/root/.local/bin:$PATH

WORKDIR /app

COPY . ./
# First we get the dependencies for the stack itself
RUN pipenv lock -r > requirements.txt
# Now add in any for the app, that the developer has added (there seems to be
# no easy way of specifying a different location for the Pipfile, so have to 
# change the working directory!)
WORKDIR /app/userapp
RUN pipenv lock -r > ../requirements.txt
# Now process the combined requirements
WORKDIR /app
RUN python -m pip install -r requirements.txt -t /project/deps
COPY requirements.txt /tmp/requirements.txt
RUN  pip install --upgrade pip \
  && pip install --upgrade pipenv\
  && pip install --upgrade -r /tmp/requirements.txt

ENV PYTHONPATH=/project/deps
ENV FLASK_APP=server/__init__.py

EXPOSE 8080
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0", "--port=8080"]