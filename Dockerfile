FROM rails-base

ADD . /app
ADD secrets/fest_prod/ssl-bundle.crt /app/config/production/nginx/site-files/fest_prod.crt
ADD secrets/fest_prod/myserver.key /app/config/production/nginx/site-files/fest_prod.key
ADD secrets/certificates/festivalfanatic.com.crt /app/config/staging/nginx/site-files/fest_staging.crt
ADD secrets/certificates/festivalfanatic.com.key /app/config/staging/nginx/site-files/fest_staging.key
RUN cd /app && \
    mkdir -p tmp/pids tmp/log && \
    bundle install --local --deployment --without development deployment test && \
    SECRET_KEY_BASE=face SMTP_PASSWORD=fake RAILS_ENV=production bin/rake assets:precompile && \
    rm /app/log/*
