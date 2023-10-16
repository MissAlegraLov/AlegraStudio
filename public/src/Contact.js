// Contact.js
import React from 'react';

function Contact() {
    return (
        <section id="contact">
            <h2>Contact Us</h2>
            <p>If you have questions or want to get involved, reach out to us!</p>
            <form>
                <label for="name">Name:</label>
                <input type="text" id="name" name="name" />

                <label for="email">Email:</label>
                <input type="email" id="email" name="email" />

                <label for="message">Message:</label>
                <textarea id="message" name="message"></textarea>

                <button type="submit">Send</button>
            </form>
        </section>
    );
}

export default Contact;
