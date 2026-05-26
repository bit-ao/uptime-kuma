const NotificationProvider = require("./notification-provider");
const axios = require("axios");

class GoWA extends NotificationProvider {
    name = "gowa";

    /**
     * Normalise a recipient entry into a WhatsApp JID.
     * Raw digits become `<digits>@s.whatsapp.net`; entries already
     * containing "@" are passed through unchanged (so group JIDs like
     * `<id>@g.us` work).
     * @param {string} raw Recipient as typed by user
     * @returns {string|null} JID, or null if entry is empty
     */
    static toJID(raw) {
        const trimmed = (raw || "").trim();
        if (!trimmed) {
            return null;
        }
        if (trimmed.includes("@")) {
            return trimmed;
        }
        const digits = trimmed.replace(/[^0-9]/g, "");
        if (!digits) {
            return null;
        }
        return digits + "@s.whatsapp.net";
    }

    /**
     * @inheritdoc
     */
    async send(notification, msg, monitorJSON = null, heartbeatJSON = null) {
        const okMsg = "Sent Successfully.";

        const baseUrl = (notification.gowaUrl || "").replace(/\/+$/, "");
        if (!baseUrl) {
            throw new Error("GoWA: base URL is required");
        }
        const endpoint = baseUrl + "/send/message";

        const recipients = (notification.gowaRecipients || "")
            .split(/[\n,;]+/)
            .map(GoWA.toJID)
            .filter((x) => x !== null);

        if (recipients.length === 0) {
            throw new Error("GoWA: at least one recipient is required");
        }

        const headers = {
            Accept: "application/json",
            "Content-Type": "application/json",
        };
        if (notification.gowaDeviceId) {
            headers["X-Device-Id"] = notification.gowaDeviceId;
        }

        let config = { headers };
        if (notification.gowaUser || notification.gowaPassword) {
            config.auth = {
                username: notification.gowaUser || "",
                password: notification.gowaPassword || "",
            };
        }
        config = this.getAxiosConfigWithProxy(config);

        try {
            for (const phone of recipients) {
                await axios.post(endpoint, {
                    phone,
                    message: msg,
                }, config);
            }
            return okMsg;
        } catch (error) {
            this.throwGeneralAxiosError(error);
        }
    }
}

module.exports = GoWA;
