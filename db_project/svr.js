const express = require('express');
const app = express();
const port = 3000;
const mysql = require('mysql2');
const dbconfig = require('./cfg/dbconfig.json');
const path = require('path')
const axios = require('axios');
const { get } = require('request');
const xml2js = require('xml2js');

let pool = mysql.createPool(dbconfig);

app.use(express.urlencoded({ extended: false }));
app.use(express.json());
app.use(express.static(path.join(__dirname, '')));

// ====================================
// openAPI 함수

async function getFishRadioactivity() {
    const endpoint = 'http://www.nfqs.go.kr/hpmg/front/api/smp_ra_api.do';
    const key = '425AABBBA37D74DEF55C04A5FFD69E3605EBAA8CF2E9D1A9B610A6392B0A364F';
    const start_dt = '20231204';
    const end_dt = '20231206';
    const url = `${endpoint}?cert_key=${key}&start_dt=${start_dt}&end_dt=${end_dt}`;

    try {
        const response = await axios.get(url);
        if (response.status === 200) {
            const xml = response.data;
            // XML을 JavaScript 객체로 변환
            const parser = new xml2js.Parser({ explicitArray: false });
            const parseString = parser.parseStringPromise;
            const result = await parseString(xml);
            if (!result.response.body.items) {
                return false;
            }
            // DataFrame 생성
            const items = result.response.body.items.item;
            const dataArray = Array.isArray(items) ? items : [items];
            return dataArray;
        }
        else {
            console.log('Error:', response.status);
            return null;
        }
    }
    catch (error) {
        console.error('Error:', error);
        return null;
    }
}

async function getregionRadio() {
    const endpoint = 'http://apis.data.go.kr/1192000/service/marineRadiationSafetyRegionInfoService/marineRadiationSafetyRegionInfoService';
    const key = 'dAaRZOk4ZP2FigNSGZSs5QfMZ1pkxtWxwR%2BmVmzs%2FqZ9p8rPDu%2FZHPU2eFZhff2KZwjP1mPzjunxgFl0%2BwM43g%3D%3D';
    const pageNo = 1
    const numOfRows = 100
    const url = `${endpoint}?serviceKey=${key}&pageNo=${pageNo}&numOfRows=${numOfRows}`;

    try {
        const response = await axios.get(url);
        if (response.status === 200) {
            const xml = response.data;
            // XML을 JavaScript 객체로 변환
            const parser = new xml2js.Parser({ explicitArray: false });
            const parseString = parser.parseStringPromise;
            const result = await parseString(xml);

            if (!result.response.body.items) {
                return false;
            }
            // DataFrame 생성
            const items = result.response.body.items.item;
            const dataArray = Array.isArray(items) ? items : [items];
            return dataArray;
        }

        else {
            console.log('Error:', response.status);
            return null;
        }

    }
    catch (error) {
        console.error('Error:', error);
        return null;
    }
}


// ==================================================
// 2가지의 API 틀

// 1. (단수 value) 틀. 깔끔해서 쓰기 좋음
app.post('/api/test', async (req, res) => {
    console.log('/api/test 호출됨');

    let conn = null;
    try {
        let QUERY_STR = `SELECT * from test_fish;`;
        conn = await new Promise((resolve, reject) => {
            pool.getConnection((err, connection) => {
                if (err) reject(err);
                resolve(connection);
            });
        }).catch((err) => {
            throw err;
        })
        const [rows] = await conn.promise().query(QUERY_STR);
        console.log(rows[0]);
        console.log('Successfully fetched the users posts list. [/api/test]');
        if (rows[0]) res.status(200).json(true);
        else res.status(404).json(false);
    } catch (err) {
        res.status(404).json({
            error: "An error occurred while /api/test"
        });
    } finally {
        if (conn) conn.release();
    }
})


// 2. (복수 vluae)insert 틀. 받아온 데이터가 여러개고, 이를 insert 해야할 경우는 위와 틀이 좀 달라짐.
app.post('/api/insertTest', async (req, res) => {
    console.log('/api/insertTest 호출됨');

    const data_array = await getFishRadioactivity();
    // console.log(data_array)

    let conn = null;
    try {
        const query = 'INSERT INTO test_fish (fish_name, is_ok) VALUES ?';
        conn = await new Promise((resolve, reject) => {
            pool.getConnection((err, connection) => {
                if (err) reject(err);
                resolve(connection);
            });
        }).catch((err) => {
            throw err;
        })

        conn.query(query, [data_array.map(item => [item.itmNm, item.charAnalRsltVal])], (err, res, fields) => {
            if (err) throw err;
            console.log('Inserted rows:', res.affectedRows);
        });

        res.json()
    } catch (err) {
        res.status(404).json({
            error: "An error occurred while /api/inserTest"
        });
    } finally {
        if (conn) conn.release();
    }
})


app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});