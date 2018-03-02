# Base the image off of the latest pre-built rails image
FROM ruby:%%RUBY_VERSION%%
CMD ruby --version
ADD entrypoint.sh /entrypoint.sh
RUN \
    apt-get update -qq && \
    apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs && \
    chmod +x /entrypoint.sh;



# move over the Gemfile and Gemfile.lock before the rest of the app so that we can cache the installed gems
#RUN mkdir /myapp

WORKDIR /app
ENTRYPOINT ["/entrypoint.sh"]

# move over the Gemfile and Gemfile.lock before the rest of the app so that we can cache the installed gems
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock

#COPY Gemfile Gemfile
#COPY Gemfile.lock Gemfile.lock

# install all gems specified by the Gemfile
RUN bundle install

# copy over the rest of the rails app files
ADD . /myapp

# start the rails server
# NOTE: The '-b 0.0.0.0' is very important!
# Especially if you are using a Mac.
CMD ["rails", "server", "-b", "0.0.0.0"]