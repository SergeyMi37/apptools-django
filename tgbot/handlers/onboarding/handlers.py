import datetime
import json
from django.utils import timezone
from telegram import ParseMode, Update
from telegram.ext import CallbackContext

from tgbot.handlers.onboarding import static_text
from tgbot.handlers.utils.info import extract_user_data_from_update
from users.models import User
from tgbot.handlers.onboarding.keyboards import make_keyboard_for_start_command
from apptools.iris import classMethod
from django.conf import settings
from telegram import Bot
from dtb.settings import TELEGRAM_TOKEN

def command_start(update: Update, context: CallbackContext) -> None:
    u, created = User.get_user_and_created(update, context)

    if created:
        text = static_text.start_created.format(first_name=u.first_name)
    else:
        text = static_text.start_not_created.format(first_name=u.first_name)
    text+="\n" + get_text_command_help()
    update.message.reply_text(text=text,
                              reply_markup=make_keyboard_for_start_command())

def get_text_command_help():
    '''
    * `/broadcast` — send message to all users (admin command)
    * `/export_users` — bot sends you info about your users in .csv file (admin command)
    * `/stats` — show basic bot stats 
    * `/ask_for_location` — log user location when received and reverse geocode it to get country, city, etc.

    'start': 'Start django bot 🚀',
    'stats': 'Statistics of bot 📊',
    'admin': 'Show admin info ℹ️',
    'ask_location': 'Send location 📍',
    'broadcast': 'Broadcast message 📨',
    'export_users': 'Export users.csv 👥',
    '''
    bot_info = Bot(TELEGRAM_TOKEN).get_me()
    bot_link = f"https://t.me/{bot_info['username']}"
    text = f"{bot_link}\n\n /help\n /start - Start django bot 🚀\n /admin Show admin info ℹ️\n /stats - Statistics of bot 📊\n /ask_location Send location 📍\n /broadcast Broadcast message 📨\n /export_users Export users.csv 👥\n /export_iris Export IRIS items .csv\n"
    return text


def command_help(update: Update, context: CallbackContext) -> None:
    u, created = User.get_user_and_created(update, context)
    text = get_text_command_help()
    update.message.reply_text(text=text)

def secret_level(update: Update, context: CallbackContext) -> None:
    # callback_data: SECRET_LEVEL_BUTTON variable from manage_data.py
    """ Pressed 'secret_level_button_text' after /start command"""
    user_id = extract_user_data_from_update(update)['user_id']
    text = static_text.unlock_secret_room.format(
        user_count=User.objects.count(),
        active_24=User.objects.filter(updated_at__gte=timezone.now() - datetime.timedelta(hours=24)).count()
    )
    _ret=json.loads(classMethod("","apptools.core.telebot", "TS", ""))
    _irishost=_ret["django"].get("irishost","undef")
    
    text+= f"\n Base_dir: <b> {settings.BASE_DIR}\n {_irishost}</b>"
    
    context.bot.edit_message_text(
        text=text,
        chat_id=user_id,
        message_id=update.callback_query.message.message_id,
        parse_mode=ParseMode.HTML
    )