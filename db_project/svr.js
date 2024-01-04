const express = require('express');
const app = express();
const port = 3000;
const mysql = require('mysql2');
const dbconfig = require('./cfg/dbconfig.json');
const path = require('path')
const axios = require('axios');
const { get } = require('request');
const xml2js = require('xml2js');
const { send } = require('process');

let pool = mysql.createPool(dbconfig);

app.use(express.urlencoded({ extended: false }));
app.use(express.json());
app.use(express.static(path.join(__dirname, '')));



// ====================================

// openAPI 함수

let nowDate = getFormattedDate();

async function getFishRadioactivity() {
    const endpoint = 'http://www.nfqs.go.kr/hpmg/front/api/smp_ra_api.do';
    const key = '425AABBBA37D74DEF55C04A5FFD69E3605EBAA8CF2E9D1A9B610A6392B0A364F';
    const start_dt = '20231207';
    const end_dt = '20231214';
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

            // // 지원 텍스트 수정
            // for(let i=0; i < dataArray.length; i++){
            //     dataArray[i].
            // }
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

// 사용자 마커 클릭 이벤트
// 지원별 수산물 방사능 검사 결과 불러오기.

app.post('/api/getRadiation', async (req, res) => {
    console.log('/api/getRadiation 호출됨');
    const location = req.body.location

    let conn = null;
    try {
        let QUERY_STR = `SELECT * from FishRadiation where fish_location = '${location}';`;
        conn = await new Promise((resolve, reject) => {
            pool.getConnection((err, connection) => {
                if (err) reject(err);
                resolve(connection);
            });
        }).catch((err) => {
            throw err;
        })
        const [rows] = await conn.promise().query(QUERY_STR);
        // console.log(rows);
        clickResultRadiation(rows);
        console.log('Successfully fetched the users posts list. [/api/getRadiation]');
        if (rows[0]) res.status(200).json(true);
        else res.status(404).json(false);
    } catch (err) {
        res.status(404).json({
            error: "An error occurred while /api/getRadiation"
        });
    } finally {
        if (conn) conn.release();
    }
})

app.post('/api/getTriplehCesium', async (req, res) => {
    console.log('/api/getTriplehCesium 호출됨');
    const location = req.body.location

    let conn = null;
    try {
        let QUERY_STR = `SELECT * from seatriplehcesium where sea_name = '${location}';`;
        conn = await new Promise((resolve, reject) => {
            pool.getConnection((err, connection) => {
                if (err) reject(err);
                resolve(connection);
            });
        }).catch((err) => {
            throw err;
        })
        const [rows] = await conn.promise().query(QUERY_STR);
        clickResultSea(rows);
        console.log('Successfully fetched the users posts list. [/api/getTriplehCesium]');
        if (rows[0]) res.status(200).json(true);
        else res.status(404).json(false);
    } catch (err) {
        res.status(404).json({
            error: "An error occurred while /api/getTriplehCesium"
        });
    } finally {
        if (conn) conn.release();
    }
})



// ==========================================================

// Server Side.
// setinterval 함수로 주기적으로 아래 2가지 API를 호출해 새로운 데이터를 받아와 DB에 저장한다.

const getAPI = async (nowDate) => {
    console.log('/api/getAPI 호출됨');

    let conn = null;
    // api 호출
    const data_array = await getFishRadioactivity(nowDate);

    // Old 버퍼 비우고, New 버퍼의 값을 Old 버퍼로 옮긴다.
    const delete_query1 = 'delete from FishRadiation_old_Buffer';
    const query1 = `insert into FishRadiation_old_Buffer (fish_name, fish_location, rad_name, char_result, sample_num) 
    select fish_name, fish_location, rad_name, char_result, sample_num from FishRadiation_new_Buffer`;

    // New 버퍼도 비우고, API를 호출해 갱신된 데이터를 New 버퍼에 넣어준다.
    const delete_query2 = 'delete from FishRadiation_new_Buffer';
    const query2 = 'insert into FishRadiation_new_Buffer (fish_name, fish_location, rad_name, char_result, sample_num) VALUES ?;';

    // {New - Old} 연산을 통해 새롭게 추가된 데이터만 뽑아 FishRatidation 테이블에 Insert
    const query3 = `insert into FishRaditon (fish_name, fish_location, rad_name, char_result, sample_num) 
    select fish_name, fish_location, rad_name, char_result, sample_num from FishRadiation_new_Buffer A 
    where not exists (select * from FishRadiation_old_buffer B where A.fish_name = B.fish_name and A.rad_name = B.rad_name and A.sample_num = B.sample_num);`;
    try {
        conn = await new Promise((resolve, reject) => {
            pool.getConnection((err, connection) => {
                if (err) reject(err);
                resolve(connection);
            });
        }).catch((err) => {
            throw err;
        })

        await Promise.all([
            // 하루 바뀌면 history 지워주기
            conn.promise().query(delete_query1),
            conn.promise().query(query1, [data_array.map(item => [item.itmNm, item.gathMchnNm.slice(0, -2), item.dtldSurvCiseNm, item.charAnalRsltVal, item.smpNo])], (err, res, fields) => {
                if (err) throw err;
                console.log('Inserted rows:', res.affectedRows);
            }),

            conn.promise().query(delete_query2),
            conn.promise().query(query2, [data_array.map(item => [item.itmNm, item.gathMchnNm.slice(0, -2), item.dtldSurvCiseNm, item.charAnalRsltVal, item.smpNo])], (err, res, fields) => {
                if (err) throw err;
                console.log('Inserted rows:', res.affectedRows);
            }),
            conn.promise().query(query3)
        ]);

        console.log('Successfully fetched the users posts list. [/api/getAPI]');
    } catch (err) {

    } finally {
        if (conn) conn.release();
    }
}


const getTripleHCesium = async (id) => {
    console.log('/api/getTripleHCesium 호출됨');
    const data_array = await getregionRadio();

    let conn = null;
    try {
        let QUERY_STR = 'INSERT INTO seatriplehcesium (sea_name, type, value, safety) VALUES ?';
        // console.log(QUERY_STR)
        conn = await new Promise((resolve, reject) => {
            pool.getConnection((err, connection) => {
                if (err) reject(err);
                resolve(connection);
            });
        }).catch((err) => {
            throw err;
        })

        conn.query(QUERY_STR, [data_array.map(item => [item.part, item.type, item.value, item.estnm])], (err, res, fields) => {
            if (err) throw err;
            console.log('Inserted rows:', res.affectedRows);
        });

        // printResult(rows);
        console.log('Successfully fetched the users posts list. [/api/getTripleHCesium]');

    } catch (err) {

    } finally {
        if (conn) conn.release();
    }
}



// =================================================

// 지원에 새로운 수산물 검사 데이터가 들어올때마다 알람을 보내는 함수

const sendAlarm = async (id) => {
    console.log('/api/sendAlarm 호출됨');

    let conn = null;
    try {
        let QUERY_STR = `select distinct B.fish_name, B.rad_name, B.fish_location, char_result, A.name
        from user_info A, fishradiation_new_buffer B
        where A.residence = B.fish_location and A.id = '${id}';`;

        conn = await new Promise((resolve, reject) => {
            pool.getConnection((err, connection) => {
                if (err) reject(err);
                resolve(connection);
            });
        }).catch((err) => {
            throw err;
        })
        const [rows] = await conn.promise().query(QUERY_STR);
        printResult(rows);
        console.log('Successfully fetched the users posts list. [/api/sendAlarm]');

    } catch (err) {

    } finally {
        if (conn) conn.release();
    }
}


// ==============================================

// 출력결과를 사용자가 보기 좋게 print해주는 함수

const printResult = (rows) => {
    console.log(`\n=============================================================`)
    if (rows.length == 0) {
        console.log('측정값 없음')
        console.log(`=============================================================\n`)
        return
    }
    console.log(`${rows[0].name} 님, ${rows[0].fish_location}지역의 수산물 방사능 검출 실시간 결과 (${rows.length}개)를 알려드립니다.\n`)

    for (let i = 0; i < rows.length; i++) {
        console.log(`어종 : ${rows[i].fish_name},  종류 : ${rows[i].rad_name},  결과 : ${rows[i].char_result}`);
    }
    console.log(`=============================================================\n`)
}

const clickResultRadiation = (rows) => {
    console.log(`\n=============================================================`)
    if (rows.length == 0) {
        console.log('측정값 없음')
        console.log(`=============================================================\n`)
        return
    }
    console.log(`${rows[0].fish_location} 지원의 최근 수산물 방사능 검출 결과 (${rows.length}개)를 알려드립니다.\n`)

    for (let i = 0; i < rows.length; i++) {
        console.log(`어종 : ${rows[i].fish_name},  종류 : ${rows[i].rad_name},  결과 : ${rows[i].char_result}`);
    }
    console.log(`=============================================================\n`)
}

const clickResultSea = (rows) => {
    console.log(`\n=============================================================`)
    console.log(`${rows[0].sea_name} 해역에서 방사능 검출 실시간 결과 (${rows.length}개)를 알려드립니다.\n`)

    for (let i = 0; i < rows.length; i++) {
        console.log(`방사능 종류 : ${rows[i].type},  수치 : ${rows[i].value},  안전등급 : ${rows[i].safety}`);
    }
    console.log(`=============================================================\n`)
}


// =================================================

// 현재 년원일 문자열로 얻는 함수
function getFormattedDate() {
    const currentDate = new Date();

    const year = currentDate.getFullYear();
    const month = (currentDate.getMonth() + 1).toString().padStart(2, '0'); // 월은 0부터 시작하므로 1을 더하고 두 자리로 패딩
    const day = currentDate.getDate().toString().padStart(2, '0'); // 일을 두 자리로 패딩

    const formattedDate = `${year}${month}${day}`;
    return formattedDate;
}


// 서버에서 일정 시간마다 주기적으로 API호출해서 데이터 얻기.
setInterval(async () => {
    console.log('서버에서 API 호출.');
    nowDate = getFormattedDate();

    await getAPI(nowDate);
    await getTripleHCesium();
    await sendAlarm('whdgus120213');

}, 60 * 60 * 1000);


app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
