from datetime import timedelta

from django.utils.timezone import now
from telegram import ParseMode, Update
from telegram.ext import CallbackContext

from tgbot.handlers.admin import static_text
from tgbot.handlers.admin.utils import _get_csv_from_qs_values
from tgbot.handlers.utils.info import send_typing_action
from users.models import User
import json
from apptools.iris import classMethod, classMethodFooter, classMethodPortal
from tgbot.system_commands import set_up_commands

def admin(update: Update, context: CallbackContext) -> None:
    """ Show help info about all secret admins commands """
    u = User.get_user(update, context)
    if not u.is_admin:
        update.message.reply_text(static_text.only_for_admins)
        return
    update.message.reply_text(static_text.secret_admin_commands)


def stats(update: Update, context: CallbackContext) -> None:
    """ Show help info about all secret admins commands """
    u = User.get_user(update, context)
    if not u.is_admin:
        update.message.reply_text(static_text.only_for_admins)
        return

    text = static_text.users_amount_stat.format(
        user_count=User.objects.count(),  # count may be ineffective if there are a lot of users.
        active_24=User.objects.filter(updated_at__gte=now() - timedelta(hours=24)).count()
    )

    update.message.reply_text(
        text,
        parse_mode=ParseMode.HTML,
        disable_web_page_preview=True,
    )


@send_typing_action
def export_users(update: Update, context: CallbackContext) -> None:
    u = User.get_user(update, context)
    if not u.is_admin:
        update.message.reply_text(static_text.only_for_admins)
        return
    # in values argument you can specify which fields should be returned in output csv
    users = User.objects.all().values()
    print(type(users), users)
    csv_users = _get_csv_from_qs_values(users)
    print(type(csv_users), csv_users)
    context.bot.send_document(chat_id=u.user_id, document=csv_users)

#--------------IRIS
def get_items_iris():
    #todo get list items from IRIS
    text = f" /iris_users Users of system👉🏻\n /iris_products Interoperability solution👉🏻\n /iris_process Process of system👉🏻\n /iris_tasks Tasks of system👉🏻\n /iris_messages Messages Log👉🏻\n /iris_i Get Items👉🏻\n"
    return text

def iris_items(**kwargs):
    _irisitem = kwargs.get('irisitem', 'default_value')
    _js = json.loads(classMethodPortal("",_irisitem+"-csv"))
    _tab=_js["table"]
    return _get_csv_from_qs_values(_tab,filename="iris-"+_irisitem)

@send_typing_action
def export_iris(update: Update, context: CallbackContext) -> None:
    u = User.get_user(update, context)
    if not u.is_admin:
        update.message.reply_text(static_text.only_for_admins)
        return
    text = get_items_iris()
    update.message.reply_text(text=text)

@send_typing_action
def iris_i(update: Update, context: CallbackContext) -> None:
    #_lg=update.message.from_user.language_code    
    u = User.get_user(update, context)
    if not u.is_admin:
        update.message.reply_text(static_text.only_for_admins)
        return
    print("=======",update)
    print("---",update.message.text)
    #_lst=' '.join(map(str,update.message.text.split(" ")[1::]))
    _lst=update.message.text.split(" ")[1]
    #update.message.reply_text(text=_lst)
    _csv_tab = iris_items(irisitem=_lst)
    context.bot.send_document(chat_id=u.user_id, document=_csv_tab)


@send_typing_action
def iris_users(update: Update, context: CallbackContext) -> None:
    u = User.get_user(update, context)
    if not u.is_admin:
        update.message.reply_text(static_text.only_for_admins)
        return
    return #to do
    _csv_tab = iris_items("Users")
    context.bot.send_document(chat_id=u.user_id, document=_csv_tab)

@send_typing_action
def iris_tasks(update: Update, context: CallbackContext) -> None:
    u = User.get_user(update, context)
    if not u.is_admin:
        update.message.reply_text(static_text.only_for_admins)
        return
    _csv_tab = iris_items(irisitem="Tasks")
    context.bot.send_document(chat_id=u.user_id, document=_csv_tab)

@send_typing_action
def iris_process(update: Update, context: CallbackContext) -> None:
    u = User.get_user(update, context)
    if not u.is_admin:
        update.message.reply_text(static_text.only_for_admins)
        return
    _csv_tab = iris_items(irisitem="Process")
    context.bot.send_document(chat_id=u.user_id, document=_csv_tab)

@send_typing_action
def iris_products(update: Update, context: CallbackContext) -> None:
    u = User.get_user(update, context)
    if not u.is_admin:
        update.message.reply_text(static_text.only_for_admins)
        return
    _csv_tab = iris_items(irisitem="Products")
    context.bot.send_document(chat_id=u.user_id, document=_csv_tab)

