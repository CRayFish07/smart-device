package co.darma.controllers;

import co.darma.common.StringUtil;
import co.darma.constant.ErrorCode;
import co.darma.constant.ErrorMessageEN;
import co.darma.constant.HttpHeadResponseCode;
import co.darma.exceptions.InvalidAccessTokenException;
import co.darma.forms.healthrecords.SittingForm;
import co.darma.models.data.PhysicalRecord;
import co.darma.models.data.SittingRecord;
import co.darma.models.returns.Argument;
import co.darma.models.returns.ValidateResult;
import co.darma.models.view.HealthDataResponseModel;
import co.darma.models.view.ResponseModel;
import co.darma.services.AuthService;
import co.darma.services.SittingService;
import co.darma.services.VersionController;
import co.darma.services.impl.AuthServiceImpl;
import co.darma.services.impl.SittingServiceImpl;
import co.darma.validate.ValidatorHandler;
import com.fasterxml.jackson.databind.JavaType;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import play.Logger;
import play.data.Form;
import play.libs.Json;
import play.mvc.Controller;
import play.mvc.Result;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by frank on 15/12/4.
 */
public class SittingController extends Controller {

    private static int ONE_YEAR = 365 * 24 * 60 * 60;

    private SittingService sittingService = SittingServiceImpl.INSTANCE;

    private AuthService authSvc = AuthServiceImpl.createInstance();

    private VersionController versionController = VersionController.INSTANCE;

    private static ObjectMapper mapper = new ObjectMapper();

    JavaType type = mapper.getTypeFactory().constructParametricType(List.class, SittingForm.class);

    public Result querySitting() {

        String accessToken = request().getHeader("AccessToken");

        try {
            Long memberId = authSvc.verifyAccessToken(accessToken);

            Long startTime = StringUtil.strToLong(request().getQueryString("start_time"));

            if (startTime == null) {
                startTime = System.currentTimeMillis() / 1000 - ONE_YEAR;
            }

            Long endTime = StringUtil.strToLong(request().getQueryString("end_time"));
            if (endTime == null) {
                endTime = System.currentTimeMillis() / 1000;
            }

            List<SittingRecord> physicalRecordList = sittingService.queryRecordsByTime(memberId, startTime, endTime);

            Map finalMap = new HashMap<String, List>(1);
            finalMap.put(SittingRecord.KEY, physicalRecordList);

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

    public Result updateSitting() {

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
                Logger.info("memberId [" + memberId + "] update SittingRecord .");

                List<SittingForm> formList = mapper.readValue(collectionStr, type);

                ValidatorHandler handler = ValidatorHandler.getValidatorHandlerByName("sitting");
                if (handler != null) {
                    ValidateResult validateResult = handler.validateList(Argument.packageToList(formList));
                    if (validateResult != null) {
                        return badRequest(Json.toJson(new ResponseModel(validateResult.getErrorCode(), validateResult.getErrorMessage())));
                    }
                }

                sittingService.updateSittingRecordList(SittingRecord.packageToRecordList(memberId, formList));
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
