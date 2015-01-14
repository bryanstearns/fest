FROM rails-base

ADD ./Gemfile /app_deps/Gemfile
ADD ./Gemfile.lock /app_deps/Gemfile.lock
RUN cd /app_deps && \
    bundle install --deployment --without development deployment test

ADD . /app
RUN mkdir -p /app/config/production/nginx/{sites-enabled,site-files} \
      /app/config/nginx/staging/{sites-enabled,site-files}
ADD secrets/fest_prod/ssl-bundle.crt /app/config/production/nginx/site-files/fest_prod.crt
ADD secrets/fest_prod/myserver.key /app/config/production/nginx/site-files/fest_prod.key
ADD secrets/certificates/festivalfanatic.com.crt /app/config/staging/nginx/site-files/fest_staging.crt
ADD secrets/certificates/festivalfanatic.com.key /app/config/staging/nginx/site-files/fest_staging.key
RUN cd /app && \
    cp /app_deps/.bundle/config .bundle/config && \
    bundle config --local path /app_deps/vendor/bundle && \
    mkdir -p /app/tmp/pids /app/tmp/log && \
    SECRET_KEY_BASE=facefacefacefacefacefacefacefacefacefaceface \
      RAILS_ENV=production bin/rake assets:precompile && \
    rm /app/log/*
