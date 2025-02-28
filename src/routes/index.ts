import { Router } from 'express';
import apiRoutes from './api.routes';

const router = Router();

router.use('/v1', apiRoutes);

export default router;