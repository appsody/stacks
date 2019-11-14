FROM python:3.7

RUN pip install --upgrade pip \
  && pip install --upgrade --user pipenv
ENV PATH=/root/.local/bin:$PATH

WORKDIR /project

COPY . ./
# First we get the dependencies for the stack itself
RUN pipenv lock -r > requirements.txt
# Now add in any for the app, that the developer has added (there seems to be
# no easy way of specifying a different location for the Pipfile, so have to 
# change the working directory!)
WORKDIR /project/userapp
RUN pipenv lock -r > ../requirements.txt
# Now process the combined requirements
WORKDIR /project
RUN python -m pip install -r requirements.txt -t /project/deps

ENV PYTHONPATH=/project/deps
ENV FLASK_APP=server/__init__.py

EXPOSE 8080
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0", "--port=8080"]