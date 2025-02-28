import { Request, Response, NextFunction } from 'express';
import logger from '../utils/logger';

export interface ApiError extends Error {
    statusCode?: number;
    details?: unknown;
}

export const errorHandler = (
    err: ApiError,
    req: Request,
    res: Response,
    next: NextFunction
): void => {
    const statusCode = err.statusCode || 500;
    const message = err.message || 'Internal Server Error';

    logger.error(`${statusCode} - ${message}`, {
        path: req.path,
        method: req.method,
        error: err.stack,
        details: err.details
    });

    res.status(statusCode).json({
        success: false,
        message,
        ...(process.env.NODE_ENV === 'development' ? { stack: err.stack } : {}),
        ...(err.details && typeof err.details === 'object' ? { details: err.details } : {})

    });
};

export const notFoundHandler = (
    req: Request,
    res: Response,
    next: NextFunction
): void => {
    const error: ApiError = new Error(`Not Found - ${req.originalUrl}`);
    error.statusCode = 404;
    next(error);
};