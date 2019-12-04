# script to start services

echo "Starting application in ${APP_ENV} environment"

# if environment is development, enable the rabbitmq management tool 
if [ "$APP_ENV" == "development" ] 
then
   echo "Enabling management console for development environment"
   rabbitmq-plugins enable rabbitmq_management
fi

echo "Starting rabbitmq server process "
service rabbitmq-server start

echo "Adding admin user"
rabbitmqctl add_user ${EVALHALLA_AMQP_USER} ${EVALHALLA_AMQP_PASSWORD}
rabbitmqctl set_user_tags ${EVALHALLA_AMQP_USER} administrator
rabbitmqctl set_permissions -p / ${EVALHALLA_AMQP_USER} ".*" ".*" ".*"
rabbitmqctl add_vhost ${EVALHALLA_AMQP_VHOST}
rabbitmqctl set_permissions -p ${EVALHALLA_AMQP_VHOST} ${EVALHALLA_AMQP_USER} ".*" ".*" ".*"



NUM_CORES=$( getconf _NPROCESSORS_ONLN )
echo "$NUM_CORES cpu cores detected on system"

echo "Starting nginx service"
service nginx start

export FLASK_ENV=${APP_ENV}
export EVALHALLA_DATABASE_HOST=${EVALHALLA_DATABASE_HOST}
export EVALHALLA_DATABASE_USER=${EVALHALLA_DATABASE_USER}
export EVALHALLA_DATABASE_NAME=${EVALHALLA_DATABASE_NAME}
export EVALHALLA_DATABASE_PASSWORD=${EVALHALLA_DATABASE_PASSWORD}
export EVALHALLA_AMQP_USER=${EVALHALLA_AMQP_USER}
export EVALHALLA_AMQP_VHOST=${EVALHALLA_AMQP_VHOST}
export EVALHALLA_AMQP_PASSWORD=${EVALHALLA_AMQP_PASSWORD}

echo "export APP_ENV=${APP_ENV}"
echo "export EVALHALLA_DATABASE_HOST=${EVALHALLA_DATABASE_HOST}" >> /etc/default/celeryd
echo "export EVALHALLA_DATABASE_USER=${EVALHALLA_DATABASE_USER}" >> /etc/default/celeryd
echo "export EVALHALLA_DATABASE_NAME=${EVALHALLA_DATABASE_NAME}" >> /etc/default/celeryd
echo "export EVALHALLA_DATABASE_PASSWORD=${EVALHALLA_DATABASE_PASSWORD}" >> /etc/default/celeryd
echo "export EVALHALLA_AMQP_USER=${EVALHALLA_AMQP_USER}" >> /etc/default/celeryd
echo "export EVALHALLA_AMQP_PASSWORD=${EVALHALLA_AMQP_PASSWORD}" >> /etc/default/celeryd
echo "export EVALHALLA_AMQP_VHOST=${EVALHALLA_AMQP_VHOST}" >> /etc/default/celeryd

echo "Starting celery workers"
service celeryd start

source venv/bin/activate
if [ "$APP_ENV" == "development" ]
then 
   echo "Starting application in development mode"
   flask run -p 8000
else
   echo "Starting application with $NUM_CORES workers"
   gunicorn -w $NUM_CORES app:app
fi




