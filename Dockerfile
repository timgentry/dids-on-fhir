FROM ruby:3.1 as data

COPY ./Gemfile ./
RUN bundle install

COPY . /dids-on-fhir/
WORKDIR /dids-on-fhir
RUN rake fake_dids.csv && rake fake_patients.yml

FROM python:3.7
COPY --from=data /dids-on-fhir/fake_dids.csv /tmp
COPY --from=data /dids-on-fhir/fake_patients.yml /tmp
