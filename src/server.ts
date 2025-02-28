import createApp from './app';
import { environment } from './config/environment';
import logger from './utils/logger';

const startServer = async (): Promise<void> => {
    try {
        const app = createApp();

        // Start listening
        const server = app.listen(environment.PORT, () => {
            logger.info(`Server running in ${environment.NODE_ENV} mode on port ${environment.PORT}`);
        });

        // Handle shutdown gracefully
        const shutdown = () => {
            logger.info('Shutting down server...');
            server.close(() => {
                logger.info('Server closed');
                process.exit(0);
            });

            // Force close after 10s
            setTimeout(() => {
                logger.error('Forcing server shutdown after timeout');
                process.exit(1);
            }, 10000);
        };

        process.on('SIGTERM', shutdown);
        process.on('SIGINT', shutdown);

    } catch (error) {
        logger.error('Failed to start server:', error);
        process.exit(1);
    }
};

// Start the server
startServer();