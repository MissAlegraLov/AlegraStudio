// App.js
import React from 'react';

// Importando los componentes individuales
import Header from './Header';
import Navigation from './Navigation';
import About from './About';
import Projects from './Projects';
import Contact from './Contact';
import Footer from './Footer';

function App() {
    return (
        <div>
            <Header />
            <Navigation />
            <About />
            <Projects />
            <Contact />
            <Footer />
        </div>
    );
}

export default App;

