# Use the official Ruby image as the base image
FROM ruby:3.2

# Set the working directory
WORKDIR /usr/src/app

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libffi-dev nodejs

# Copy the Gemfile and Gemfile.lock into the container
COPY Gemfile Gemfile.lock ./

# Install the required gems
RUN gem install bundler:2.7.1 && bundle install

# Copy the rest of the application into the container
COPY . .

# Expose port 4000 for Jekyll
EXPOSE 4000

# Command to run Jekyll server
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0"]
