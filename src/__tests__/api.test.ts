import request from 'supertest';
import createApp from '../app';

describe('API Routes', () => {
    const app = createApp();

    describe('GET /api/v1', () => {
        it('should return 200 status and correct message', async () => {
            const response = await request(app).get('/api/v1');

            expect(response.status).toBe(200);
            expect(response.body).toHaveProperty('message', 'API is working properly');
            expect(response.body).toHaveProperty('version');
        });
    });
});