FROM quay.io/aptible/alpine

# Install Ruby & Bundler
RUN apk-install ruby ruby-json git ca-certificates ruby-io-console \
  ruby-bigdecimal
RUN gem install -N bundler
ADD . /opt/minitron
WORKDIR /opt/minitron
RUN bundle install

ENV PORT 3000
ENV RACK_ENV production
EXPOSE 3000

CMD bundle exec ruby minitron.rb

