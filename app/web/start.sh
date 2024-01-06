#!/bin/bash
export PORT=3000
export API_HOST=http://external-load-balancer-1784107043.us-east-1.elb.amazonaws.com
export CDN_HOST=https://dzew1p18vi060.cloudfront.net
npm start 2>&1 | tee /home/ubuntu/web.log