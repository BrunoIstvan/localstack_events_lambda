import requests
import os

os.environ['HOST_API_JSON'] = '172.28.1.2'

HOST_API_JSON = os.environ['HOST_API_JSON']


def lambda_handler(event, context):

    # resp = requests.get(f'http://{HOST_API_JSON}:3000/posts/')
    #
    # if resp.status_code != 200:
    #     raise Exception(f'/GET /posts/ {resp.status_code}')
    #
    # ret = list()
    #
    # print(f'Original Response: {resp.json()}')
    #
    # for post in resp.json():
    #     ret.append({'codigo': post['id'], 'titulo': post['title'], 'autor': post['author']})
    #
    # print(f'Translated Response: {ret}')

    return {
        'statusCode': 200,
        # 'body': ret
        'body': { 'message': 'Lambda called by API GATEWAY' }
    }


if __name__ == '__main__':
    lambda_handler(None, None)