<template>
    <div class="mb-3">
        <label for="gowa-url" class="form-label">{{ $t("Base URL") }}</label>
        <input
            id="gowa-url"
            v-model="$parent.notification.gowaUrl"
            type="url"
            placeholder="http://localhost:3000"
            pattern="https?://.+"
            class="form-control"
            required
        />
        <div class="form-text">
            URL of the running <a href="https://github.com/aldinokemal/go-whatsapp-web-multidevice" target="_blank">go-whatsapp-web-multidevice</a> instance, without trailing slash.
        </div>
    </div>

    <div class="row">
        <div class="col-md-6 mb-3">
            <label for="gowa-user" class="form-label">{{ $t("Username") }}</label>
            <input
                id="gowa-user"
                v-model="$parent.notification.gowaUser"
                type="text"
                autocomplete="off"
                class="form-control"
            />
        </div>
        <div class="col-md-6 mb-3">
            <label for="gowa-password" class="form-label">{{ $t("Password") }}</label>
            <HiddenInput
                id="gowa-password"
                v-model="$parent.notification.gowaPassword"
                autocomplete="new-password"
            />
        </div>
    </div>
    <div class="form-text mb-3">
        Basic Auth credentials configured on the GoWA server (<code>--basic-auth user:pass</code> or <code>APP_BASIC_AUTH</code>). Leave both empty if GoWA is running without auth.
    </div>

    <div class="mb-3">
        <label for="gowa-device" class="form-label">X-Device-Id</label>
        <input
            id="gowa-device"
            v-model="$parent.notification.gowaDeviceId"
            type="text"
            autocomplete="off"
            class="form-control"
        />
        <div class="form-text">
            Optional. Required when GoWA is running multi-account; copy the device id from the GoWA dashboard.
        </div>
    </div>

    <div class="mb-3">
        <label for="gowa-recipients" class="form-label">{{ $t("Recipients") }}</label>
        <textarea
            id="gowa-recipients"
            v-model="$parent.notification.gowaRecipients"
            class="form-control"
            placeholder="244923123456&#10;244923987654@s.whatsapp.net&#10;120363012345678901@g.us"
            required
        ></textarea>
        <div class="form-text">
            One destination per line (or comma-separated). Plain numbers (with country code, no <code>+</code>) are treated as private chats. To send to a group, paste its full JID ending in <code>@g.us</code> (obtainable via GoWA <code>GET /app/group</code>).
        </div>
    </div>
</template>

<script>
import HiddenInput from "../HiddenInput.vue";

export default {
    components: {
        HiddenInput,
    },
};
</script>

<style lang="scss" scoped>
textarea {
    min-height: 100px;
    font-family: monospace;
}
</style>
