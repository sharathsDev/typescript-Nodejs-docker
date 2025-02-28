import express, { Express } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import { errorHandler, notFoundHandler } from './middleware/error.middleware';
import routes from './routes';
import logger from './utils/logger';

const createApp = (): Express => {
    const app = express();

    // Apply middleware
    app.use(helmet());
    app.use(cors());
    app.use(compression());
    app.use(express.json());
    app.use(express.urlencoded({ extended: true }));

    // Request logging middleware
    app.use((req, res, next) => {
        logger.info(`${req.method} ${req.path}`);
        next();
    });

    // Apply routes
    app.use('/api', routes);

    // Health check endpoint
    app.get('/health', (req, res) => {
        res.status(200).json({ status: 'ok' });
    });

    // Handle 404s
    app.use(notFoundHandler);

    // Handle errors
    app.use(errorHandler);

    return app;
};

export default createApp;