package co.darma.controllers;

import co.darma.common.StringUtil;
import co.darma.constant.ErrorCode;
import co.darma.constant.ErrorMessageEN;
import co.darma.constant.HttpHeadResponseCode;
import co.darma.exceptions.InvalidAccessTokenException;
import co.darma.forms.healthrecords.BehaviorForm;
import co.darma.forms.healthrecords.SedentaryForm;
import co.darma.models.data.BehaviorRecord;
import co.darma.models.data.SedentaryRecord;
import co.darma.models.returns.Argument;
import co.darma.models.returns.ValidateResult;
import co.darma.models.view.HealthDataResponseModel;
import co.darma.models.view.ResponseModel;
import co.darma.services.AuthService;
import co.darma.services.BehaviorService;
import co.darma.services.VersionController;
import co.darma.services.impl.AuthServiceImpl;
import co.darma.services.impl.BehaviorServiceImpl;
import co.darma.validate.ValidatorHandler;
import com.fasterxml.jackson.databind.JavaType;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import play.Logger;
import play.libs.Json;
import play.mvc.Controller;
import play.mvc.Result;
import sun.rmi.runtime.Log;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by frank on 15/12/1.
 */
public class BehaviorController extends Controller {

    private static int ONE_YEAR = 365 * 24 * 60 * 60;

    private BehaviorService behaviorService = BehaviorServiceImpl.INSTANCE;

    private AuthService authSvc = AuthServiceImpl.createInstance();

    private VersionController versionController = VersionController.INSTANCE;

    private static ObjectMapper mapper = new ObjectMapper();

    JavaType type = mapper.getTypeFactory().constructParametricType(List.class, BehaviorForm.class);


    public Result queryBehaviors() {
        String accessToken = request().getHeader("AccessToken");

        try {
            Long memberId = authSvc.verifyAccessToken(accessToken);

            Logger.info("memberId is :" + memberId);

            Long startTime = StringUtil.strToLong(request().getQueryString("start_time"));

            if (startTime == null) {
                startTime = System.currentTimeMillis() / 1000 - ONE_YEAR;
            }

            Long endTime = StringUtil.strToLong(request().getQueryString("end_time"));
            if (endTime == null) {
                endTime = System.currentTimeMillis() / 1000;
            }

            Logger.info("startTime:" + startTime + ",endTime:" + endTime);
            List<BehaviorRecord> behaviorList = behaviorService.queryRecordsByTime(memberId, startTime, endTime);

            Map finalMap = new HashMap<String, List>(1);
            finalMap.put(BehaviorRecord.KEY, behaviorList);

            return ok(Json.toJson(finalMap));
        } catch (InvalidAccessTokenException e) {
            e.printStackTrace();
            ResponseModel model = new ResponseModel(
                    ErrorCode.TOKEN_INVALID, ErrorMessageEN.TOKEN_INVALID);
            return unauthorized(Json.toJson(model));
        } catch (Exception e) {
            e.printStackTrace();
            return internalServerError(Json.toJson(new ResponseModel(
                    ErrorCode.SERVER_ERROR, "System error.")));
        }
    }


    public Result updateBehavior() {
        JsonNode rquestJson = request().body().asJson();
        String accessToken = request().getHeader("AccessToken");
        try {
            Long memberId = authSvc.verifyAccessToken(accessToken);
            if (rquestJson == null) {
                return badRequest(Json.toJson(new ResponseModel(
                        ErrorCode.INVALID_ARGUMENT,
                        "Request body should be Json format.")));
            }

            Long appLastUpdateTime = rquestJson.get("lastUpdateTime").asLong();
            Long userLastUpdateTime = versionController.getLastVersionbyMemberId(memberId);

            if (appLastUpdateTime < userLastUpdateTime) {
                Logger.error("appLastUpdateTime :" + appLastUpdateTime + ",userLastUpdateTime : " + userLastUpdateTime);
                ResponseModel model = new ResponseModel(
                        ErrorCode.RESOURCE_EXPIRE, "lastUpdateTime:" + userLastUpdateTime.toString());
                return status(HttpHeadResponseCode.RESOURCELOCKED, Json.toJson(model));
            }

            JsonNode collections = rquestJson.get("collections");

            if (collections != null) {
                String collectionStr = collections.toString();
                Logger.info("memberId [" + memberId + "] update BehaviorRecord .");

                List<BehaviorForm> formList = mapper.readValue(collectionStr, type);

                ValidatorHandler handler = ValidatorHandler.getValidatorHandlerByName("behavior");
                if (handler != null) {
                    ValidateResult validateResult = handler.validateList(Argument.packageToList(formList));
                    if (validateResult != null) {
                        return badRequest(Json.toJson(new ResponseModel(validateResult.getErrorCode(), validateResult.getErrorMessage())));
                    }
                }

                behaviorService.updateBehaviorRecordList(BehaviorRecord.packageToRecordList(memberId, formList));
                Logger.info("Behavior form list is :" + formList);
                userLastUpdateTime = versionController.getLastVersionbyMemberId(memberId);
                return ok(Json.toJson(new HealthDataResponseModel(userLastUpdateTime)));
            } else {
                return badRequest(Json.toJson(new HealthDataResponseModel(ErrorCode.INVALID_ARGUMENT, "[collections] should not be null.")));
            }
        } catch (InvalidAccessTokenException e) {
            e.printStackTrace();
            ResponseModel model = new ResponseModel(
                    ErrorCode.TOKEN_INVALID, ErrorMessageEN.TOKEN_INVALID);
            return unauthorized(Json.toJson(model));
        } catch (Exception e) {
            e.printStackTrace();
            return internalServerError(Json.toJson(new ResponseModel(
                    ErrorCode.SERVER_ERROR, "System error.")));
        }

    }
}
