import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  IonHeader, IonToolbar, IonTitle, IonContent, IonButtons,
  IonBackButton, IonCard, IonCardHeader, IonCardTitle,
  IonCardSubtitle, IonCardContent, IonChip, IonLabel,
  IonAccordionGroup, IonAccordion, IonItem, IonIcon,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import {
  schoolOutline, rocketOutline, peopleOutline,
  trophyOutline, bulbOutline, codeSlashOutline,
} from 'ionicons/icons';

interface Pioneer {
  name: string;
  years: string;
  role: string;
  achievement: string;
  era: string;
}

interface Era {
  title: string;
  period: string;
  icon: string;
  summary: string;
  pioneers: Pioneer[];
  milestones: string[];
}

@Component({
  selector: 'app-african-americans-cs',
  templateUrl: './african-americans-cs.page.html',
  styleUrls: ['./african-americans-cs.page.scss'],
  standalone: true,
  imports: [
    CommonModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonButtons,
    IonBackButton, IonCard, IonCardHeader, IonCardTitle,
    IonCardSubtitle, IonCardContent, IonChip, IonLabel,
    IonAccordionGroup, IonAccordion, IonItem, IonIcon,
  ],
})
export class AfricanAmericansCsPage {
  eras: Era[] = [
    {
      title: 'The Foundational Era',
      period: '1940s – 1960s',
      icon: 'bulb-outline',
      summary:
        'African Americans began making critical contributions to computing during its earliest days, ' +
        'often overcoming segregation and systemic racism to work on groundbreaking projects.',
      pioneers: [
        {
          name: 'Evelyn Boyd Granville',
          years: '1924 – 2023',
          role: 'Mathematician & Computer Programmer',
          achievement:
            'One of the first African American women to earn a Ph.D. in mathematics (Yale, 1949). ' +
            'She worked at IBM developing computer programs for NASA\'s Project Mercury and Project Apollo, ' +
            'computing satellite orbits and trajectories that helped put Americans in space.',
          era: 'foundational',
        },
        {
          name: 'Katherine Johnson',
          years: '1918 – 2020',
          role: 'NASA Mathematician & "Human Computer"',
          achievement:
            'A NASA mathematician whose orbital mechanics calculations were critical to the success ' +
            'of the first U.S. crewed spaceflights. John Glenn personally requested she verify the ' +
            'electronic computer\'s trajectory calculations before his orbital mission in 1962. ' +
            'Awarded the Presidential Medal of Freedom in 2015.',
          era: 'foundational',
        },
        {
          name: 'Dorothy Vaughan',
          years: '1910 – 2008',
          role: 'Mathematician & Programming Pioneer',
          achievement:
            'The first African American woman to supervise a group of staff at NACA (later NASA). ' +
            'She taught herself and her staff FORTRAN programming, becoming an expert programmer ' +
            'on the IBM 704 and transitioning her group from human computers to electronic computing.',
          era: 'foundational',
        },
        {
          name: 'Mary Jackson',
          years: '1921 – 2005',
          role: 'NASA\'s First Black Female Engineer',
          achievement:
            'After petitioning the City of Hampton, Virginia to be allowed to attend whites-only ' +
            'graduate-level courses, she became NASA\'s first Black female aerospace engineer in 1958. ' +
            'She later managed NASA\'s Federal Women\'s Program to advocate for the hiring and promotion ' +
            'of women in science and engineering.',
          era: 'foundational',
        },
        {
          name: 'Jesse Ernest Wilkins Jr.',
          years: '1923 – 2011',
          role: 'Mathematician & Nuclear Scientist',
          achievement:
            'Entered the University of Chicago at age 13, becoming the youngest-ever student at the time. ' +
            'He contributed to the Manhattan Project and later developed mathematical models fundamental ' +
            'to nuclear reactor design and radiation shielding computations.',
          era: 'foundational',
        },
      ],
      milestones: [
        '1949 — Evelyn Boyd Granville earns her Ph.D. from Yale, one of the first two African American women to earn a math doctorate.',
        '1953 — Dorothy Vaughan becomes the first Black supervisor at NACA\'s West Area Computing unit.',
        '1958 — Mary Jackson becomes NASA\'s first African American female engineer.',
        '1961 — Katherine Johnson calculates the trajectory for Alan Shepard\'s Freedom 7 mission.',
        '1962 — John Glenn requests Katherine Johnson personally verify the electronic computer\'s orbital calculations.',
      ],
    },
    {
      title: 'Breaking Barriers in Academia',
      period: '1960s – 1980s',
      icon: 'school-outline',
      summary:
        'African American computer scientists began earning advanced degrees and establishing themselves ' +
        'in academia, often as the first in their field, creating pathways for future generations.',
      pioneers: [
        {
          name: 'Clarence "Skip" Ellis',
          years: '1943 – 2014',
          role: 'Computer Scientist & Groupware Pioneer',
          achievement:
            'The first African American to earn a Ph.D. in Computer Science (University of Illinois, 1969). ' +
            'He was a pioneer of Computer-Supported Cooperative Work (CSCW) and groupware, ' +
            'contributing to operational transformation algorithms used in collaborative editing tools ' +
            'like Google Docs. He also worked on the Illiac IV supercomputer at Xerox PARC.',
          era: 'academia',
        },
        {
          name: 'Mark Dean',
          years: '1957 – present',
          role: 'Computer Engineer & IBM Fellow',
          achievement:
            'Co-creator of the IBM Personal Computer (1981) and holds three of the original nine patents ' +
            'on the IBM PC architecture. He led the team that developed the ISA bus, enabling peripherals ' +
            'to plug into PCs. Later led the team creating the first 1-GHz processor chip. ' +
            'Named an IBM Fellow — the company\'s highest technical honor.',
          era: 'academia',
        },
        {
          name: 'Roscoe Giles',
          years: '1947 – present',
          role: 'Computational Physicist',
          achievement:
            'One of the first African Americans to earn a Ph.D. in physics from MIT. ' +
            'He became a leader in high-performance computing and computational physics at Boston University, ' +
            'and has been instrumental in broadening participation in computing through leadership ' +
            'in the National Center for Supercomputing Applications.',
          era: 'academia',
        },
        {
          name: 'Valerie Thomas',
          years: '1943 – present',
          role: 'Inventor & NASA Scientist',
          achievement:
            'Invented the Illusion Transmitter (patented 1980), a device that uses concave mirrors ' +
            'to create optical illusions of 3D images — a precursor to modern 3D display technology. ' +
            'She managed the development of NASA\'s Landsat image-processing system and ' +
            'served as a computer data analyst at NASA for over 30 years.',
          era: 'academia',
        },
      ],
      milestones: [
        '1969 — Clarence "Skip" Ellis becomes the first African American to earn a Ph.D. in Computer Science.',
        '1973 — The National Society of Black Engineers (NSBE) is founded.',
        '1975 — Earl "Ed" Pace Jr. becomes one of the first African Americans in cybersecurity at the Department of Defense.',
        '1980 — Valerie Thomas patents the Illusion Transmitter for 3D imaging.',
        '1981 — Mark Dean co-invents the IBM Personal Computer, revolutionizing personal computing.',
      ],
    },
    {
      title: 'The Rise of Tech Industry Leaders',
      period: '1980s – 2000s',
      icon: 'rocket-outline',
      summary:
        'African Americans rose to leadership positions in the growing technology industry, ' +
        'founding companies, leading research labs, and driving innovations that shaped the modern digital world.',
      pioneers: [
        {
          name: 'Roy Clay Sr.',
          years: '1929 – 2024',
          role: 'Computer Engineer & Entrepreneur',
          achievement:
            'Often called the "Godfather of Silicon Valley" for the African American tech community. ' +
            'He was recruited by David Packard to lead software development at Hewlett-Packard in the 1960s, ' +
            'where he led the team that created the HP 2116A — HP\'s first computer. ' +
            'He later founded Rod-L Electronics and served on the Palo Alto City Council.',
          era: 'industry',
        },
        {
          name: 'Jerry Lawson',
          years: '1940 – 2011',
          role: 'Video Game Pioneer',
          achievement:
            'Designed the Fairchild Channel F (1976), the first commercial home video game console ' +
            'with interchangeable cartridges — an innovation that became the standard for the entire ' +
            'video game industry. Without his work, the modern gaming industry as we know it would not exist.',
          era: 'industry',
        },
        {
          name: 'Marian Croak',
          years: '1955 – present',
          role: 'VP of Engineering at Google',
          achievement:
            'Holds over 200 patents, primarily in Voice over Internet Protocol (VoIP) technology. ' +
            'Her work was fundamental to enabling voice communication over the internet, ' +
            'which powers modern tools like Zoom, Google Meet, and VoIP phone services. ' +
            'She was inducted into the National Inventors Hall of Fame in 2022.',
          era: 'industry',
        },
        {
          name: 'John Henry Thompson',
          years: '1959 – present',
          role: 'Software Inventor',
          achievement:
            'Invented the Lingo programming language used in Macromedia Director (later Adobe Director), ' +
            'which powered countless multimedia applications, CD-ROMs, and early web experiences. ' +
            'His scripting language was a cornerstone of interactive media in the 1990s and early 2000s.',
          era: 'industry',
        },
        {
          name: 'Marc Hannah',
          years: '1956 – present',
          role: 'Co-founder of Silicon Graphics (SGI)',
          achievement:
            'Co-founded Silicon Graphics Inc. and served as principal scientist, designing the geometry ' +
            'engines and 3D graphics chips that powered SGI workstations. These machines created the special ' +
            'effects in Jurassic Park, Terminator 2, and were used by NASA for visualization.',
          era: 'industry',
        },
        {
          name: 'Lisa Gelobter',
          years: '1971 – present',
          role: 'Tech Executive & Internet Pioneer',
          achievement:
            'Played a key role in the development of Shockwave — a foundational technology for web animation. ' +
            'She held senior positions at BET, Hulu, and the U.S. Digital Service. ' +
            'She later founded tEQuitable, a platform to address workplace inequity in tech.',
          era: 'industry',
        },
      ],
      milestones: [
        '1976 — Jerry Lawson creates the first cartridge-based home video game console.',
        '1986 — Marc Hannah co-founds Silicon Graphics, powering Hollywood visual effects.',
        '1995 — John Henry Thompson\'s Lingo language powers the multimedia revolution.',
        '1999 — Mark Dean leads IBM\'s team to create the first 1-GHz processor chip.',
        '2002 — The Anita Borg Institute and Grace Hopper Celebration begin spotlighting diversity in tech.',
      ],
    },
    {
      title: 'Modern Innovators & Culture Shapers',
      period: '2000s – Present',
      icon: 'people-outline',
      summary:
        'Today, African Americans are leading transformative work in AI, cybersecurity, social platforms, ' +
        'entrepreneurship, and advocacy — reshaping technology and working to make the industry more inclusive.',
      pioneers: [
        {
          name: 'Kimberly Bryant',
          years: '1967 – present',
          role: 'Founder of Black Girls CODE',
          achievement:
            'Founded Black Girls CODE in 2011 to introduce young girls of color to technology and computer ' +
            'programming. The organization has reached tens of thousands of students across the U.S. and ' +
            'South Africa, empowering the next generation of Black women in tech.',
          era: 'modern',
        },
        {
          name: 'Timnit Gebru',
          years: '1982 – present',
          role: 'AI Ethics Researcher',
          achievement:
            'A leading researcher in AI ethics and algorithmic bias. Co-authored the landmark paper ' +
            '"Gender Shades" exposing racial and gender bias in facial recognition systems. ' +
            'Founded the Distributed AI Research Institute (DAIR) to conduct independent, community-rooted AI research.',
          era: 'modern',
        },
        {
          name: 'Joy Buolamwini',
          years: '1989 – present',
          role: 'Computer Scientist & Digital Activist',
          achievement:
            'Founded the Algorithmic Justice League at MIT Media Lab. Her research on bias in facial ' +
            'recognition technology led directly to major companies halting sales of facial recognition ' +
            'to law enforcement. Her documentary "Coded Bias" brought algorithmic accountability ' +
            'to mainstream awareness.',
          era: 'modern',
        },
        {
          name: 'Tristan Walker',
          years: '1984 – present',
          role: 'Tech Entrepreneur',
          achievement:
            'Founder of Walker & Company Brands (acquired by Procter & Gamble), he was also an early ' +
            'business development lead at Foursquare. A Stanford MBA graduate and advocate for ' +
            'increasing Black representation in Silicon Valley\'s startup ecosystem.',
          era: 'modern',
        },
        {
          name: 'Rediet Abebe',
          years: '1991 – present',
          role: 'Computer Scientist',
          achievement:
            'The first Black woman to earn a Ph.D. in computer science from Cornell. ' +
            'Co-founded Mechanism Design for Social Good (MD4SG), which uses algorithms and AI ' +
            'to address social inequality. She is an assistant professor at UC Berkeley.',
          era: 'modern',
        },
        {
          name: 'Dr. Juan Gilbert',
          years: '1969 – present',
          role: 'Chair of Computer & Information Science, University of Florida',
          achievement:
            'A leading researcher in human-computer interaction and accessible voting technology. ' +
            'His Prime III electronic voting system was designed to be universally accessible. ' +
            'He has produced more Black Ph.D. graduates in computing than any other faculty member in the U.S.',
          era: 'modern',
        },
      ],
      milestones: [
        '2011 — Kimberly Bryant founds Black Girls CODE, expanding STEM access for young Black women.',
        '2016 — The #BlackTechTwitter movement amplifies the voices of Black professionals in technology.',
        '2018 — Joy Buolamwini\'s "Gender Shades" paper exposes racial bias in AI systems globally.',
        '2019 — /dev/color, a nonprofit supporting Black software engineers, reaches thousands of members.',
        '2020 — Major tech companies pledge billions toward racial equity initiatives after social justice movements.',
        '2022 — Marian Croak inducted into the National Inventors Hall of Fame for VoIP technology.',
      ],
    },
    {
      title: 'Continuing the Legacy: Arts & Technology',
      period: 'The Intersection',
      icon: 'code-slash-outline',
      summary:
        'The intersection of African American culture, performing arts, and technology continues ' +
        'to drive innovation — from music production software to dance motion-capture technology, ' +
        'streaming platforms, and creative AI tools that amplify Black artistic expression.',
      pioneers: [
        {
          name: 'Robert Frederick Smith',
          years: '1962 – present',
          role: 'Tech Investor & Philanthropist',
          achievement:
            'Founder of Vista Equity Partners, the largest Black-owned business in the U.S. ' +
            'A former software engineer, he has donated hundreds of millions to STEM education, ' +
            'including paying off the student loans of the entire Morehouse College Class of 2019.',
          era: 'arts-tech',
        },
        {
          name: 'Ketra Armstrong',
          years: 'Contemporary',
          role: 'Sports Technology & Cultural Innovation',
          achievement:
            'Pioneered research at the intersection of race, technology, and sports culture, ' +
            'advancing the use of analytics and digital platforms in communities historically excluded from tech.',
          era: 'arts-tech',
        },
      ],
      milestones: [
        'Music production platforms like FL Studio and Ableton have roots in innovations championed by Black artists and engineers.',
        'Motion-capture technology is being used to preserve and teach traditional African and African American dance forms.',
        'Streaming platforms have democratized distribution for Black performing artists worldwide.',
        'AI-driven music and art tools are being developed with input from Black creators to ensure cultural representation.',
        'HBCUs are expanding computer science and digital arts programs to serve the next generation of innovators.',
      ],
    },
  ];

  constructor() {
    addIcons({
      schoolOutline, rocketOutline, peopleOutline,
      trophyOutline, bulbOutline, codeSlashOutline,
    });
  }
}
