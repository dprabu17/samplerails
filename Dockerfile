# Start from the official ruby image, then update and install JS & DB
FROM ruby:2.6.0
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client apt-transport-https ca-certificates

# Create a directory for the application and use it
RUN mkdir /myapp
WORKDIR /myapp

# Gemfile and lock file need to be present, they'll be overwritten immediately
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

# Install gem dependencies
RUN bundle install
COPY . /myapp

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \ 
 && apt-get install -y nodejs

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y yarn
#RUN yarn install
RUN yarn install --check-files

# This script runs every time the container is created, necessary for rails
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start rails
CMD ["rails", "server", "-b", "0.0.0.0"]
