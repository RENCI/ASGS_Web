import os
import slack


class SlackMsgs:

    def __init__(self):
        # instantiate slack connectivity
        self.slack_client = slack.WebClient(token=os.getenv('SLACK_ISSUES_TOKEN'))
        self.slack_channel = os.getenv('SLACK_ISSUES_CHANNEL')

    def send_slack_msg(self, source, msg):

        # create the final msg, prefix with source
        final_msg = f"Context: {source}: {msg}"

        self.slack_client.chat_postMessage(channel=self.slack_channel, text=final_msg)